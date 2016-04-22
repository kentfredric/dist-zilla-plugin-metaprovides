use 5.006;
use strict;
use warnings;

package Dist::Zilla::MetaProvides::ProvideRecord;

our $VERSION = '2.002001';

# ABSTRACT: Data Management Record for MetaProvider::Provides Based Class

# AUTHORITY

use Moose qw( has );
use MooseX::Types::Moose qw( Str );
use Dist::Zilla::MetaProvides::Types qw( ModVersion ProviderObject );

use namespace::autoclean;

=begin MetaPOD::JSON v1.1.0

{
    "namespace":"Dist::Zilla::MetaProvides::ProvideRecord",
    "interface":"class",
    "inherits":"Moose::Object"
}

=end MetaPOD::JSON

=cut

=attr version

See L<Dist::Zilla::MetaProvides::Types/ModVersion>

=cut

has version => ( isa => ModVersion, is => 'ro', required => 1 );

=attr module

The String Name of a fully qualified module to be reported as
included in the distribution.

=cut

has module => ( isa => Str, is => 'ro', required => 1 );

=attr file

The String Name of the file as to be reported in the distribution.

=cut

has file => ( isa => Str, is => 'ro', required => 1 );

=attr parent

A L<Dist::Zilla::MetaProvides::Types/ProviderObject>, mostly to get Zilla information
and accessors from L<Dist::Zilla::Role::MetaProvider::Provider>

=cut

has parent => (
  is       => 'ro',
  required => 1,
  weak_ref => 1,
  isa      => ProviderObject,
  handles  => [ 'zilla', '_resolve_version', ],
);

__PACKAGE__->meta->make_immutable;
no Moose;

=method copy_into C<( \%provides_list )>

Populate the referenced C<%provides_list> with data from this Provide Record object.

This is called by the  L<Dist::Zilla::Role::MetaProvider::Provider> Role.

This is very convenient if you have an array full of these objects, for you can just do

    my %discovered;
    for ( @array ) {
       $_->copy_into( \%discovered );
    }

and C<%discovered> will be populated with relevant data.

=cut

sub copy_into {
  my $self  = shift;
  my $dlist = shift;
  $dlist->{ $self->module } = {
    file => $self->file,
    $self->_resolve_version( $self->version ),
  };
  return 1;
}

1;
