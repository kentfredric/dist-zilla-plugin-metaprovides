use 5.006;
use strict;
use warnings;

package Dist::Zilla::MetaProvides::Types;

our $VERSION = '2.002004';

# ABSTRACT: Utility Types for the MetaProvides Plugin

# AUTHORITY

=begin MetaPOD::JSON v1.1.0

{
    "namespace":"Dist::Zilla::MetaProvides::Types",
    "interface":"exporter",
    "inherits":"MooseX::Types::Base"
}

=end MetaPOD::JSON

=cut

use MooseX::Types::Moose qw( Str Undef Object );
use MooseX::Types -declare => [qw( ModVersion ProviderObject )];

=subtype ModVersion

Module Versions can be either a string, or an undef.

In L<Dist::Zilla::MetaProvides::ProvideRecord> and
L<Dist::Zilla::Role::MetaProvider::Provider>, versions that have a value of
undef will be trimmed from output.

=cut

## no critic (Bangs::ProhibitBitwiseOperators)
subtype ModVersion, as Str | Undef;

=subtype ProviderObject

Just an easy to use Check that assures a given object performs a role.

=cut

subtype ProviderObject, as Object, where { $_->does('Dist::Zilla::Role::MetaProvider::Provider') };

1;

=head1 SEE ALSO

=over 4

=item * L<MooseX::Types::Moose>

=item * L<Moose::Util::TypeConstraints>

=item * L<Dist::Zilla::MetaProvides::ProvideRecord>

=item * L<Dist::Zilla::Role::MetaProvider::Provider>

=back

=cut
