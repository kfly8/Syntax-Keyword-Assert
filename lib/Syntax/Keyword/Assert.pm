package Syntax::Keyword::Assert 0.10;

use v5.14;
use warnings;

use constant STRICT => $ENV{SYNTAX_KEYWORD_ASSERT_STRICT} || 0;

use Carp qw( croak );

require XSLoader;
XSLoader::load( __PACKAGE__, our $VERSION );

sub import {
   my $pkg = shift;
   my $caller = caller;

   $pkg->import_into( $caller, @_ );
}

sub unimport {
   my $pkg = shift;
   my $caller = caller;

   $pkg->unimport_into( $caller, @_ );
}

sub import_into   { shift->apply( sub { $^H{ $_[0] }++ },      @_ ) }
sub unimport_into { shift->apply( sub { delete $^H{ $_[0] } }, @_ ) }

sub apply {
   my $pkg = shift;
   my ( $cb, $caller, @syms ) = @_;

   @syms or @syms = qw( assert );

   my %syms = map { $_ => 1 } @syms;
   $cb->( "Syntax::Keyword::Assert/assert" ) if delete $syms{assert};

   croak "Unrecognised import symbols @{[ keys %syms ]}" if keys %syms;
}

1;
__END__

=encoding utf-8

=head1 NAME

Syntax::Keyword::Assert - It's new $module

=head1 SYNOPSIS

    use Syntax::Keyword::Assert;

=head1 DESCRIPTION

Syntax::Keyword::Assert is ...

=head1 LICENSE

Copyright (C) kobaken.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 AUTHOR

kobaken E<lt>kentafly88@gmail.comE<gt>

=cut

