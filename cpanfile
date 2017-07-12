requires 'perl', '5.008005';

requires 'Module::Runtime';
requires 'Net::Amazon::DynamoDB::Marshaler';
requires 'Paws';
requires 'PerlX::Maybe';
requires 'Scalar::Util';

on test => sub {
    requires 'Test::Deep';
    requires 'Test::DescribeMe';
    requires 'Test::Fatal';
    requires 'Test::More', '0.96';
    requires 'UUID::Tiny';
};
