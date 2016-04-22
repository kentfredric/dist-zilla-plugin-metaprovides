use 5.006;
use strict;
use warnings;

package Dist::Zilla::Role::MetaProvider::Provider;

our $VERSION = '2.002001';

# ABSTRACT: A Role for Metadata providers specific to the 'provider' key.

our $AUTHORITY = 'cpan:KENTNL'; # AUTHORITY

use Moose::Role qw( with requires has around );
use MooseX::Types::Moose qw( Bool );
use namespace::autoclean;



















with 'Dist::Zilla::Role::MetaProvider';








requires 'provides';























has inherit_version => (
  is            => 'ro',
  isa           => Bool,
  default       => 1,
  documentation => 'Whether or not to treat the global version as an authority',
);






















has inherit_missing => (
  is            => 'ro',
  isa           => Bool,
  default       => 1,
  documentation => <<'DOC',
How to behave when we are trusting modules to have versions and one is missing one
DOC
);






















has meta_noindex => (
  is            => 'ro',
  isa           => Bool,
  default       => 1,
  documentation => <<'DOC',
Scan for the meta_noindex metadata key and do not add provides records for things in it
DOC
);



















sub _resolve_version {
  my $self    = shift;
  my $version = shift;
  if ( $self->inherit_version
    or ( $self->inherit_missing and not defined $version ) )
  {
    return ( 'version', $self->zilla->version );
  }
  if ( not defined $version ) {
    return ();
  }
  return ( 'version', $version );
}















sub _try_regen_metadata {
  my ($self) = @_;

  my $meta = {};

  for my $plugin ( @{ $self->zilla->plugins } ) {
    next unless $plugin->isa('Dist::Zilla::Plugin::MetaNoIndex');
    require Hash::Merge::Simple;
    $meta = Hash::Merge::Simple::merge( $meta, $plugin->metadata );
  }
  return $meta;
}













sub _apply_meta_noindex {
  my ( $self, @items ) = @_;

  # meta_noindex application is disabled
  if ( not $self->meta_noindex ) {
    return @items;
  }

  my $meta = $self->_try_regen_metadata;

  if ( not keys %{$meta} or not exists $meta->{no_index} ) {
    $self->log_debug( q{No no_index attribute found while trying to apply meta_noindex for} . $self->plugin_name );
    return @items;
  }
  else {
    $self->log_debug(q{no_index found in metadata, will apply rules});
  }

  my $noindex = {

    # defaults
    file      => [],
    package   => [],
    namespace => [],
    dir       => [],
    %{ $meta->{'no_index'} },
  };
  $noindex->{dir} = $noindex->{directory} if exists $noindex->{directory};

  for my $file ( @{ $noindex->{file} } ) {
    @items = grep { $_->file ne $file } @items;
  }
  for my $module ( @{ $noindex->{'package'} } ) {
    @items = grep { $_->module ne $module } @items;
  }
  for my $dir ( @{ $noindex->{'dir'} } ) {
    ## no critic (RegularExpressions ProhibitPunctuationVars)
    @items = grep { $_->file !~ qr{^\Q$dir\E($|/)} } @items;
  }
  for my $namespace ( @{ $noindex->{'namespace'} } ) {
    ## no critic (RegularExpressions ProhibitPunctuationVars)
    @items = grep { $_->module !~ qr{^\Q$namespace\E::} } @items;
  }
  return @items;
}

use Dist::Zilla::Util::ConfigDumper 0.002001 qw( config_dumper );

around dump_config => config_dumper(
  __PACKAGE__,
  { attrs => [qw( inherit_version inherit_missing meta_noindex )] },
  sub { $_[1]->{ __PACKAGE__ . '::VERSION' } = $VERSION },
);

no Moose::Role;








sub metadata {
  my ($self) = @_;
  my $discover = {};
  for ( $self->provides ) {
    $_->copy_into($discover);
  }
  return { provides => $discover };
}

1;

__END__

=pod

=encoding UTF-8

=head1 NAME

Dist::Zilla::Role::MetaProvider::Provider - A Role for Metadata providers specific to the 'provider' key.

=head1 VERSION

version 2.002001

=head1 PUBLIC METHODS

=head2 C<metadata>

Fulfills the requirement of L<Dist::Zilla::Role::MetaProvider> by processing
results returned from C<$self-E<gt>provides>.

=head1 ATTRIBUTES / PARAMETERS

=head2 C<inherit_version>

This dictates how to report versions.

=head3 values

=over 4

=item * Set to "1" B<[default]>
The version defined by L<Dist::Zilla> is the authority, and all versions
discovered in packages are ignored.

=item * Set to "0"
The version defined in the discovered class is the authority, and it is copied
to the provides metadata.

=back

( To use this feature in a performing class, see L</_resolve_version> )

=head2 C<inherit_missing>

This dictates how to react when a class is discovered but a version is not
specified.

=head3 values

=over 4

=item * Set to "1" B<[default]>
C<dist.ini>'s version turns up in the final metadata.

=item * Set to "0".
A C<provide> turns up in the final metadata without a version, which is permissible.

=back

( To use this feature in a performing class, see L</_resolve_version> )

=head2 C<meta_noindex>

This dictates how to behave when a discovered class is also present in the C<no_index> META field.

=head3 values

=over 4

=item * Set to "0" B<[default]>

C<no_index> META field will be ignored

=item * Set to "1"

C<no_index> META field will be recognised and things found in it will cause respective packages
to not be provided in the metadata.

=back

=head1 PERFORMS ROLES

=head2 MetaProvider

L<Dist::Zilla::Role::MetaProvider>

=head1 REQUIRED METHODS FOR PERFORMING ROLES

=head2 C<provides>

Must return an array full of L<Dist::Zilla::MetaProvides::ProvideRecord>
instances.

=head1 PRIVATE METHODS

=head2 C<_resolve_version>

This is a utility method to make performing classes life easier in adhering to
user requirements.

    my $params  = {
        file => $somefile ,
        $self->_resolve_version( $version );
    }

is the suggested use.

Returns either an empty list, or a list with C<('version', $version )>;

This is so C<{ version =E<gt> undef }> does not occur in the YAML.

=head2 C<_try_regen_metadata>

This is a nasty hack really, to work around the way L<< C<Dist::Zilla>|Dist::Zilla >> handles
metaproviders, which result in meta-data being inaccessible to metadata Plugins.

  my $meta  = $object->_try_regen_metadata()

This at present returns metadata provided by  L<< C<MetaNoIndex>|Dist::Zilla::Plugin::MetaNoIndex >> ( if present )
but will be expanded as needed.

If you have a module you think should be in this list, contact me, or file a bug, I'll do my best ☺

=head2 C<_apply_meta_noindex>

This is a utility method to make performing classes life easier in skipping no_index entries.

  my @filtered_provides = $self->_apply_meta_noindex( @provides )

is the suggested use.

Returns either an empty list, or a list of C<ProvideRecord>'s

=begin MetaPOD::JSON v1.1.0

{
    "namespace":"Dist::Zilla::Role::MetaProvider::Provider",
    "interface":"role",
    "does":"Dist::Zilla::Role::MetaProvider"
}


=end MetaPOD::JSON

=head1 SEE ALSO

=over 4

=item * L<Dist::Zilla::Role::MetaProvider>

=item * L<Dist::Zilla::Plugin::MetaProvider>

=item * L<Dist::Zilla::MetaProvides::ProvideRecord>

=back

=head1 THANKS

=over 4

=item * Thanks to David Golden ( xdg / DAGOLDEN ) for the suggestion of the no_index feature
for compatibility with MetaNoIndex plugin.

=back

=head1 AUTHOR

Kent Fredric <kentnl@cpan.org>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2016 by Kent Fredric <kentfredric@gmail.com>.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
