package Framework::Strings;

use base qw(Exporter);

our @EXPORT = qw(S_INVALID_PATH S_SQLCONF);

use constant S_INVALID_PATH => "Invalid Path.";
use constant S_SQLCONF => "Critical SQL Error.";

1;
