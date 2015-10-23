package Exporter::Rinci;

# DATE
# VERSION

use Exporter ();

sub import {
    my $package = shift;
    my $caller  = caller;

    my $export      = \@{"$caller::EXPORT"};
    my $export_ok   = \@{"$caller::EXPORT_OK"};
    my $export_tags = \%{"$caller::EXPORT"};

    {
        last if @$export || @$export_ok || keys(%$export_tags);
        my $metas = \%{"$caller\::SPEC"};

        for my $k (keys %$metas) {
            # for now we limit ourselves to subs
            next unless $k =~ /\A\w+\z/;
            my @tags = @{ $metas->{$k}{tags} // [] };
            next if grep {$_ eq 'export:never'} @tags;
            if (grep {$_ eq 'export:default'} @tags) {
                push @$export, $k;
            } else {
                push @$export_ok, $k;
            }
            for my $tag (@tags) {
                s/\Aexport://;
                push @{ $export_tags->{$tag} }, $k;
            }
        }
    }

  SKIP:
    goto &Exporter::import;
}

1;
# ABSTRACT: A simple wrapper for Exporter for modules with Rinci metadata

=head1 SYNOPSIS

 package YourModule;

 # most of the time, you only need to do this
 use Exporter::Rinci qw(import);

 our %SPEC;

 # f1 will not be exported by default, but user can import them explicitly using
 # 'use YourModule qw(f1)'
 $SPEC{f1} = { v=>1.1 };
 sub f1 { ... }

 # f2 will be exported by default because it has the export:default tag
 $SPEC{f2} = { v=>1.1, tags=>[qw/a export:default/] };
 sub f2 { ... }

 # f3 will never be exported, and user cannot import them via 'use YourModule
 # qw(f1)' nor via 'use YourModule qw(:a)'
 $SPEC{f3} = { v=>1.1, tags=>[qw/a export:never/] };
 sub f3 { ... }


=head1 DESCRIPTION

Exporter::Rinci is a simple wrapper for L<Exporter>. Before handing out control
to Exporter's import(), it will look at the exporting module's C<@EXPORT>,
C<@EXPORT_OK>, and C<%EXPORT_TAGS> and if they are empty will fill them out with
data from Rinci metadata (C<%SPEC>). The rules are similar to
L<Perinci::Exporter>: all functions will be put in C<@EXPORT_OK>, except
functions with C<export:never> tag will not be exported and functions with
C<export:default> tag will be put in C<@EXPORT>. C<%EXPORT_TAGS> will also be
filled from functions' tags.


=head1 SEE ALSO

L<Perinci::Exporter>

=cut
