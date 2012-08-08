require 'savon'
require 'bigdecimal'
require_relative 'olap_result'

Savon.configure do |config|
  config.soap_version = 1
  config.log = false
end

HTTPI.log = false

module XMLA

  class Cube
    attr_reader :query, :catalog

    def Cube.execute(query, catalog = XMLA.catalog)
      OlapResult.new(Cube.new(query, catalog).as_table)
    end

    def Cube.execute_members(query, catalog = XMLA.catalog)
      Cube.new(query, catalog).axes
    end

    def Cube.execute_scalar(query, catalog = XMLA.catalog)
      BigDecimal.new Cube.new(query, catalog).as_table[0][:value]
    end

    def as_table
      return [table] if y_size == 0
      clean_table(table).reduce([]) { |result, row|
        flat_row = row.flatten
        result << flat_row unless flat_row.all?(&:blank?)
        result
      }
    end

    def axes
      axes = all_axes.select { |axe| axe[:@name] != "SlicerAxis" }
      @axes ||= axes.reduce([]) do |result, axe|
        result << tuple(axe).reduce([]) { |y, member|
          data = (member[0] == :member) ? member[1] : member[:member]
          if ( data.class == Hash || data.size == 1 )
            # y << [data[:caption].strip].flatten
            y << [data].flatten
            # y << [Hash[*data.map{|d| [d.first,d.last.to_s]}.flatten]].flatten
          else
            y << data.select { |item_data| item_data.class == Hash }.reduce([]) do |z,item_data|
              z << [item_data].flatten
              # z << item_data[:caption].strip
            end
          end
        }
      end
    end

    private

    #header and rows
    def table
      if (header.size == 1 && y_size == 0)
        cell_data[0]
      else
        (0...y_axe.size).reduce(header) do |result, j|
          values = (0...x_size).map { |i| cell_data[i + j + ((x_size - 1) * j)] }
          result << ( y_axe[j] + values) if values.any?{|d| !d.blank? && !d[:value].blank? } && y_axe[j].any?{|d| !d.blank? }
          result
        end
      end
    end

    def header
      [ ( (0..y_size - 1).reduce([]) { |header| header << '' } << x_axe).flatten ]
    end


    def initialize(query, catalog)
      @query = query
      @catalog = catalog
      @response = get_response
      # puts @response.http.raw_body
      self
    end

    def get_response
      client = Savon::Client.new do
        wsdl.document = File.expand_path("../../wsdl/xmla.xml", __FILE__)
        wsdl.endpoint = XMLA.endpoint
      end

      @response = client.request :execute,  xmlns:"urn:schemas-microsoft-com:xml-analysis" do
        soap.body = Cube.request_body(query, catalog)
      end
    end

    #cleanup table so items don't repeat (if they are same)
    def clean_table(table)
      table.uniq_by do |row|
        row.map(&:hash).join
      end
    end

    def cell_data
      cell_data = @response.to_hash[:execute_response][:return][:root][:cell_data]
      return {} if cell_data.nil?
      @data ||= [(cell_data[:cell])].flatten.reduce({}) do |data,cell|
        data.tap do|data|
          data[cell.delete(:@cell_ordinal).to_i] = cell.class == Hash ? cell : {:value => cell[1]} rescue debugger
        end
      end
    end

    def tuple axe
      axe[:tuples].nil? ? [] : axe[:tuples][:tuple]
    end

    def all_axes
      @response.to_hash[:execute_response][:return][:root][:axes][:axis]
    end

    def x_axe
      @x_axe ||= axes[0]
    end

    def y_axe
      @y_axe ||= axes[1]
    end

    def y_size
      (y_axe.nil? || y_axe[0].nil?) ? 0 : y_axe[0].size
    end

    def x_size
      x_axe.size
    end

    def Cube.request_body(query, catalog)
      <<-REQUEST
      <Command>
      <Statement> <![CDATA[ #{query} ]]> </Statement>
        </Command>
        <Properties>
        <PropertyList>
        <Catalog>#{catalog}</Catalog>
        <Format>Multidimensional</Format>
        <AxisFormat>TupleFormat</AxisFormat>
        </PropertyList>
        </Properties>
        REQUEST
    end
  end
end


