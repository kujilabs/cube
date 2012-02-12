#encoding: utf-8
require 'cube'
require 'webmock'
require 'vcr'
require 'guerrilla_patch'

VCR.config do |c|
  c.cassette_library_dir = 'spec/cassettes'
  c.stub_with :webmock
end

XMLA.configure do |c|
 c.endpoint = "http://localhost:8282/icCube/xmla"
 c.catalog = "GOSJAR"
end


describe XMLA::Cube do
  it 'supports multiple items on x axis' do
   VCR.use_cassette('kvatovi_u_koloni') do
      result = XMLA::Cube.execute("select [Lokacija].[Kvart].children  on COLUMNS, [Measures].[Broj] on ROWS from [GOSJAR]") 
      result.size.should == 2
      result[0].split('|').size.should == 18
      result[1].should == "Broj|1422|2259|2148|2733|2004|2607|2829|1611|2581|1945|3602|1356|1696|2327|1228|3186|"
   end
  end

  it 'supports multiple items on y axis' do
   VCR.use_cassette('kvartovi_u_recima') do
      result =  XMLA::Cube.execute("select [Measures].[Broj]  on COLUMNS, non empty topcount( [Lokacija].[Kvart].children, 100,  [Measures].[Broj]) on ROWS from [GOSJAR]")
      result.size.should == 17
      result[0].should == '|Broj'
      result[6].should == 'TRESNJEVKA - JUG|2607'
      result[16].should == 'PODSLJEME|1228'
    end
  end

  it 'support multiple items on y axis and multiple items on x axis' do
   VCR.use_cassette('razlog_prijave_i_kvart') do
     result = XMLA::Cube.execute("select [Measures].[Broj]  on COLUMNS, non empty topcount ( [Razlog prijave].[Razlog].children * [Lokacija].[Kvart].children , 20,  [Measures].[Broj] ) on ROWS from [GOSJAR]")
      result.size.should == 21
      result[0].should == "||Broj"
      result[2].should == "|GORNJA DUBRAVA|1383"
      result[20].should == "Redovna izmjena|GORNJA DUBRAVA|575"
    end
  end

  it 'should connect to mondrian' do
   XMLA.configure do |c|
     c.endpoint = "http://localhost:8383/mondrian/xmla"
     c.catalog = "GOSJAR"
   end

   VCR.use_cassette('mondrian_broj_intervencija') do

    result = XMLA::Cube.execute("SELECT NON EMPTY {Hierarchize({[Measures].[Broj intervencija]})} ON COLUMNS, NON EMPTY {Hierarchize({[Gradska cetvrt].[Gradska cetvrt].Members})} ON ROWS FROM [Kvarovi]")

    result.size.should == 17
    result[0].should == "|Broj intervencija"
    result[2].should == "GORNJI GRAD – MEDVEŠČAK|2259"
   end
  end

end
