#encoding: utf-8
require 'spec_helper'




describe XMLA::Cube do
  it 'supports multiple items on x axis' do
    configure_icube
    VCR.use_cassette('kvatovi_u_koloni') do
      result = XMLA::Cube.execute("select [Lokacija].[Kvart].children  on COLUMNS, [Measures].[Broj] on ROWS from [GOSJAR]") 
      result.rows.count.should == 1
      result.header.count.should == 18
      result.rows.join('|').should == "Broj|1422|2259|2148|2733|2004|2607|2829|1611|2581|1945|3602|1356|1696|2327|1228|3186|"
    end
  end

  it 'supports multiple items on y axis' do
    configure_icube
    VCR.use_cassette('kvartovi_u_recima') do
      result =  XMLA::Cube.execute("select [Measures].[Broj]  on COLUMNS, non empty topcount( [Lokacija].[Kvart].children, 100,  [Measures].[Broj]) on ROWS from [GOSJAR]")
      result.rows.count.should == 16
      result.header.join('|').should == '|Broj'
      result.rows[5].join('|').should == 'TRESNJEVKA - JUG|2607'
      result.rows[15].join('|').should == 'PODSLJEME|1228'
    end
  end

  it 'support multiple items on y axis and multiple items on x axis' do
    configure_icube
    VCR.use_cassette('razlog_prijave_i_kvart') do
      result = XMLA::Cube.execute("select [Measures].[Broj]  on COLUMNS, non empty topcount ( [Razlog prijave].[Razlog].children * [Lokacija].[Kvart].children , 20,  [Measures].[Broj] ) on ROWS from [GOSJAR]")
      result.rows.count.should == 20
      result.header.join('|').should == "||Broj"
      result.rows[1].join('|').should == "|GORNJA DUBRAVA|1383"
      result.rows[19].join('|').should == "Redovna izmjena|GORNJA DUBRAVA|575"
    end
  end

  it 'check if request is correct - to fix that bug with class varables not beign visible inside the block' do
    configure_icube
    XMLA::Cube.send(:request_body, "SELECT", "GOSJAR").gsub("\n","").gsub(" ", "").should == 
      "<Command><Statement><![CDATA[SELECT]]></Statement></Command><Properties><PropertyList><Catalog>GOSJAR</Catalog>
       <Format>Multidimensional</Format><AxisFormat>TupleFormat</AxisFormat></PropertyList></Properties>".gsub("\n","").gsub(" ","")
  end

  it 'should connect to mondrian' do
    configure_mondrian

    VCR.use_cassette('mondrian_broj_intervencija') do
      result = XMLA::Cube.execute("SELECT NON EMPTY {Hierarchize({[Measures].[Broj intervencija]})} ON COLUMNS, NON EMPTY {Hierarchize({[Gradska cetvrt].[Gradska cetvrt].Members})} ON ROWS FROM [Kvarovi]")
      result.rows.count.should == 16
      result.header.join('|').should == "|Broj intervencija"
      result.rows[1].join('|').should == "GORNJI GRAD – MEDVEŠČAK|2,259"
    end
  end

  it 'should handle the case with only one row in result' do
    configure_mondrian

    VCR.use_cassette('mondrian_jedan_red_odgovor') do
      result = XMLA::Cube.execute <<-MDX
       SELECT NON EMPTY {Hierarchize({[Measures].[Broj intervencija]})} ON COLUMNS,
              non empty ( { Filter (Hierarchize({[Razlog prijave].children}), [Measures].[Broj intervencija] >= 7000  )}) ON ROWS
       FROM [Kvarovi]
      MDX
      result.rows.count.should == 1
      result.header.join('|').should == "|Broj intervencija"
      result.rows[0].join('|').should == "Ne radi svjetiljka|14442"
    end
  end


  it 'should handle the case with zero rows in result' do
    configure_mondrian

    VCR.use_cassette('mondrian_nula_redaka') do
      result = XMLA::Cube.execute <<-MDX
       SELECT NON EMPTY {Hierarchize({[Measures].[Broj intervencija]})} ON COLUMNS,
              non empty ( { Filter (Hierarchize({[Razlog prijave].children}), [Measures].[Broj intervencija] >= 15000  )}) ON ROWS
       FROM [Kvarovi]
      MDX
      result.rows.count.should == 0
      result.rows[0].should == nil
    end
  end

  it 'should handle when scalar value is returned' do
    configure_mondrian

    VCR.use_cassette('mondrian_scalar_value') do
      result = XMLA::Cube.execute_scalar <<-MDX
       SELECT {Hierarchize({[Measures].[Rok otklona]})} ON COLUMNS
       FROM [Kvarovi]
       WHERE [Vrijeme prijave].[2011]
      MDX
      result.should == 7.356
    end

  end


  it "should return formatted value if available" do
    configure_mondrian

    VCR.use_cassette('formatted_values') do
      result = XMLA::Cube.execute <<-MDX
        SELECT { [Measures].[Scope 1 Carbon] } on COLUMNS,
               { [Category].[Energy].Children } on ROWS
        FROM [Carbon]
        WHERE [Date].[Year].[2009]
      MDX
      result.rows[0][1].should == "3,813,012"
      result.rows[1][1].should == "3,046,551"
    end

  end

  describe "getting the members only" do
    before { configure_mondrian }

    it "should allow queries with just column" do
      VCR.use_cassette('member_query', :match_requests_on => [:body]) do
        result = XMLA::Cube.execute_members <<-MDX
        SELECT { [Category].[Energy].Children } on COLUMNS
        FROM [Carbon]
        MDX
        result.should == [[["Electricity"], ["Natural Gas"]]]
      end
    end

    it "should allow queries with just column" do
      VCR.use_cassette('member_query', :match_requests_on => [:body] ) do
        result = XMLA::Cube.execute_members <<-MDX
        SELECT { [Category].[Energy].Children } on COLUMNS,
               { [Entity].LastChild } on ROWS
        FROM [Carbon]
        MDX
        result.should == [[["Electricity"], ["Natural Gas"]], [["Wrythe Green Surgery - General Practitioner"]]]
      end
    end
  end
end
