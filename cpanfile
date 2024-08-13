requires 'perl', '5.016000';
requires 'XS::Parse::Keyword' => '0.36';

on 'configure' => sub {
  requires 'Module::Build' => '0.4004';
  requires 'Module::Build::XSUtil', '0.19';
  requires 'XS::Parse::Keyword::Builder' => '0.36';
};

on 'test' => sub {
  requires 'Test2::V0' => '0.000147';
}
