package PawsX::DynamoDB::DocumentClient;

use strict;
use 5.008_005;

use Module::Runtime qw(require_module);
use Scalar::Util qw(blessed);
use Paws;

our $VERSION = '0.01';

sub new {
    my ($class, %args) = @_;
    my $region = $args{region} || $ENV{AWS_DEFAULT_REGION};
    my $paws = $args{paws};

    if ($paws && !(blessed($paws) && $paws->isa('Paws'))) {
        die "paws must be a Paws object";
    }

    if (!$region && $paws) {
        $region = $paws->config->region;
    }

    if (!$region) {
        die "unable to determine region";
    }

    if (!$paws) {
        $paws = Paws->new(config => { region => $region});
    }

    my $self = {
        paws => $paws,
    };

    return bless $self, $class;
}

sub put {
    my ($self, %args) = @_;
    my $command_class = 'PawsX::DynamoDB::DocumentClient::Put';
    $self->_run_command($command_class, %args);
}

sub get {
    my ($self, %args) = @_;
    my $command_class = 'PawsX::DynamoDB::DocumentClient::Get';
    $self->_run_command($command_class, %args);
}

sub _service {
    my ($self) = @_;
    return $self->{paws}->service('DynamoDB');
}

sub _run_command {
    my ($self, $command_class, %args) = @_;
    my $return_paws_output = delete $args{return_paws_output} || 0;

    require_module($command_class);

    my $service = $self->_service;
    my %service_args = $command_class->transform_arguments(%args);
    my $output = $command_class->run_service_command($service, %service_args);

    return $output if $return_paws_output;
    return $command_class->transform_output($output);
}

1;
__END__

=encoding utf-8

=head1 NAME

PawsX::DynamoDB::DocumentClient - a simplified way of working with AWS DynamoDB items that uses Paws under the hood.

=head1 SYNOPSIS

  use PawsX::DynamoDB::DocumentClient;

  my $dynamodb = PawsX::DynamoDB::DocumentClient->new();

  $dynamodb->put(
      TableName => 'users',
      Item => {
          user_id => 24,
          email => 'bob@example.com',
          roles => ['admin', 'finance'],
      },
  );

  my $user = $dynamodb->get(
      TableName => 'users',
      Key => {
          user_id => 24,
      },
  );

=head1 DESCRIPTION

Paws (in this author's opinion) is to best and most up-to-date way of working with AWS. However, reading and writing DynamoDB items via Paws' low-level API calls can involve a lot of busy work formatting your data structures to includd DynamoDB types.

This module simplifies some DynamoDB operations by automatically converting back and forth between simpler Perl data structures and the request/response data structures used by Paws.

For more information about how data structures are transformed, see L<Net::Amazon::DynamoDB::Marshaler>.

This module is based on a similar class in the L<AWS JavaScript SDK|http://docs.aws.amazon.com/AWSJavaScriptSDK/latest/AWS/DynamoDB/DocumentClient.html>

=head2 outputs

By default, the methods below return plain values (or nothing) that make normal use cases simpler, as opposed to the output objects that Paws generates. For example, get() returns a hashref of the item's data, as opposed to a L<Paws::DynamoDB::GetItemOutput> object.

For use cases where you need more extensive output data, every method supports a return_paws_output flag, which will return the Paws object instead.

=head1 METHODS

=head2 new

  my $dynamodb = PawsX::DynamoDB::DocumentClient->new(
      region => 'us-east-1',
  );

This class method returns a new PawsX::DynamoDB::DocumentClient object. It accepts the following parameters:

=head3 paws

A Paws object to use to create the Paws::DynamoDB service object. Optional. Available in case you need to custom configuration of Paws (e.g. authentication).

=head3 region

The AWS region to use when creating the Paws::DynamoDB service object. If not specified, will try to grab from the AWS_DEFAULT_REGION	environment variable. Will be ignored if provided with a paws object that has a region configured.

If we can't figure out what region to use, an error will be thrown.

=head2 batch_get

  my $result = $dynamodb->batch_get(
      RequestItems => {
          $table_name => {
              Keys => [
                  { user_id => 1000 },
                  { user_id => 1001 },
              ],
          },
      },
  );

Returns the attributes of one or more items from one or more tables by delegating to Paws::DynamoDB::BatchGetItem().

=head2 batch_write

  my $result = $dynamodb->batch_write(
      RequestItems => {
          $table_name => [
              {
                  PutRequest => {
                      Item => {
                          user_id => 1000,
                          email => 'jdoe@example.com',
                      },
                  },
              },
              {
                  DeleteRequest => {
                      Key => {
                          user_id => 1001,
                      },
                  },
              },
          ],
      },
  );

Puts or deletes multiple items in one or more tables by delegating to Paws::DynamoDB::BatchWriteItem().

=head2 delete

  my $result = $dynamodb->delete(
      TableName => 'users',
      Key => {
          user_id => 1001,
      },
  );

Deletes a single item in a table by primary key by delegating to Paws::DynamoDB::DeleteItem().

=head2 get

  my $result = $dynamodb->get(
      TableName => 'users',
      Key => {
          user_id => 1000,
      },
  );

Returns a set of attributes for the item with the given primary key by delegating to Paws::DynamoDB::GetItem().

The following arguments are marshalled: 'Key'.

By default (return_paws_output not set), returns the fetched item as an unmarshalled hashref, or undef if the item was not found.

=head2 put

  my $result = $dynamodb->put(
      TableName => 'users',
      Item => {
          user_id => 1000,
          email => 'jdoe@example.com',
          tags => ['foo', 'bar', 'baz'],
      },
  );

Creates a new item, or replaces an old item with a new item by delegating to L<Paws::DynamoDB::PutItem>.

The following arguments are marshalled: 'ExpressionAttributeValues', 'Item'.

By default (return_paws_output not set), returns undef.

=head2 query

  my $result = $dynamodb->query(
      TableName => 'users',
      IndexName => 'company_id',
      KeyConditionExpression => 'company_id = :company_id',
      ExpressionAttributeValues => {
          ':company_id' => 25,
      },
  );

Directly access items from a table by primary key or a secondary index by delegating to Paws::DynamoDB::Query().

=head2 scan

  my $result = $dynamodb->scan(
      TableName => 'users',
      FilterExpression => 'first_name = :first_name',
      ExpressionAttributeValues => {
          ':first_name' => 'John',
      },
  );

Returns one or more items and item attributes by accessing every item in a table or a secondary index by delegating to Paws::DynamoDB::Scan().

=head2 update

  my $result = $dynamodb->update(
      TableName => 'users',
      Key: {
          user_id => 1000,
      },
      UpdateExpression: 'SET status = :new_status',
      ExpressionAttributeValues => {
          ':new_status' => 'active',
      },
  );

Edits an existing item's attributes, or adds a new item to the table if it does not already exist by delegating to Paws::DynamoDB::UpdateItem().

=head1 AUTHOR

Steve Caldwell E<lt>scaldwell@gmail.comE<gt>

=head1 COPYRIGHT

Copyright 2017- Steve Caldwell

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 SEE ALSO

=cut
