package Framework::Base;

use Data::Dumper;
use base qw(Exporter);
use Encode qw(decode encode);
use Plack::Util::Accessor qw(rethrow);

our @EXPORT = (
  @Data::Dumper::EXPORT,
  qw/rethrow Exporter encode decode rethrow/
);


1;
