use strict;
use warnings;

package Dist::Zilla::Plugin::MetaProvides;

# ABSTRACT: Generating and Populating 'provides' in your META.yml

1;

__END__

=head1 SYNOPSIS

In your projects dist.ini

    [MetaProvides::Class]
    inherit_version = 0    ;optional flag
    inherit_missing = 0    ;optional flag

    [MetaProvides::Package]
    inherit_version = 0    ;optional flag
    inherit_missing = 0    ;optional flag

    [MetaProvides::FromFile]
    inherit_version = 0     ;optional flag
    inherit_missing = 0     ;optional flag
    file = some_file.ini    ;mandatory flag
    reader_name = Config::INI::Reader ;optional flag

And then in some_file.ini

    [Imaginary::Package]
    file = lib/Imaginary/Package.pm ;mandatory flag
    version = 3.1415                ;optional flag, subject to rules in dist.ini


=head1 DESCRIPTION

This Distribution Contains a small bundle of plugins for various ways of
populating the C<META.yml> that is built with your distribution.

The initial reason for this is due to stuff that uses L<MooseX::Declare>
style class definitions not being parseable by many tools upstream, so this
is here to cover this problem by defining it in the metadata.

=head1 COMPONENT SUMMARY

=head2 ::Class

Scans L<Dist::Zilla>'s C<.pm> files and tries to identify classes using
L<Class::Discover>.

L<Dist::Zilla::Plugin::MetaProvides::Class>

=head2 ::Package

Scans L<Dist::Zilla>'s C<.pm> files and tries to identify more traditional
packages using a combination of L<Module::Extract::VERSION> and
L<Module::Extact::Namespaces>.

L<Dist::Zilla::Plugin::MetaProvides::Package>

=head2 ::FromFile

In the event both of the above don't work for your needs, pull in
hand-crafted metadata from a specified file.

L<Dist::Zilla::Plugin::MetaProvides::FromFile>

=head1 OPTION SUMMARY

=head2 inherit_version

At the time this plugin runs to collect metadata from files,
the mungers won't have run yet to inject custom versions into files in the various
locations.

If you want the versions reported in the C<provides> list to be consistent with
the ones actually in the files, you will need to use this option in its enabled
state.

IE: Generally, if you are using version munging, you B<WILL> want this flag set
to C<1>.

=head3 values

=over 4

=item * C<< '0' >>

Do not inherit version from C<Dist::Zilla>

=item * C<< '1' >> B<[default]>

Inherit version from L<Dist::Zilla>

=back

L<Dist::Zilla::Role::MetaProvider::Provider/inherit_version>

=head2 inherit_missing

If for whatever reason you want to actually use the versions found in the modules
where present, and fall back to the value from L<Dist::Zilla>.

C<inherit_version> will need to be turned off (C<0>) for this to be effective.

=head3 values

=over 4

=item * C<< '0' >>

Do not inherit version from C<Dist::Zilla> when one is missing.

=item * C<< '1' >> B<[default]>

Inherit version from L<Dist::Zilla> when one is missing.

=back

L<Dist::Zilla::Role::MetaProvider::Provider/inhert_missing>

=head2 file

( L<Dist::Zilla::Plugin::MetaProvides::FromFile> )

This is a mandatory parameter that points to the file that contains manually
( or otherwise ) crafted metadata to be integrated into your final META.yml

File Must exist.

=head2 reader_name

( L<Dist::Zilla::Plugin::MetaProvides::FromFile> )

This parameter is by default L<Config::INI::Reader>, but it can be infact anything
that meets the following criteria.

=over 4

=item * Can be initalized an instance of

=item * has a read_file method on the instance

=item * read_file can take the parameter 'file'

=item * read_file can return a hashref matching the following structure

    { 'Package::Name' => {
        'file' => '/path/to/file',
        'version' => 0.1,
    }}

=back

=cut
