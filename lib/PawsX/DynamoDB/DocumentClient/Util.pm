package PawsX::DynamoDB::DocumentClient::Util;

use strict;
use 5.008_005;

use parent qw(Exporter);
our @EXPORT_OK = qw(make_arg_transformer);

use Net::Amazon::DynamoDB::Marshaler;

sub make_arg_transformer {
    my %args = @_;
    my $method_name = $args{method_name} || die;
    my $to_marshall = $args{to_marshall} || die;
    my %to_marshall = map { $_ => 1 } @$to_marshall;
    return sub {
        my ($name, $val) = @_;
        return $val unless $to_marshall{$name};
        die "$method_name(): $name must be a hashref"
            unless ref $val && ref $val eq 'HASH';
        return dynamodb_marshal($val);
    };
}

1;
__END__
