requires 'perl', '5.008005';

requires 'Net::Amazon::DynamoDB::Marshaler';
requires 'Paws';
requires 'Scalar::Util';

on test => sub {
    requires 'Test::More', '0.96';
};
