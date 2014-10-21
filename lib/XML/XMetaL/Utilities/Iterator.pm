package XML::XMetaL::Utilities::Iterator;

use strict;
use warnings;

use Carp;
use Hash::Util qw(lock_keys);

use constant TRUE  => 1;
use constant FALSE => 0;

sub new {
    my ($class, %args) = @_;
    my $self;
    eval {
        lock_keys(%args, qw(-domnode -filter));
        die "-domnode argument is missing or not a DOM node type"
            unless $args{-domnode}->{nodeType};
        die "-filter argument is missing, or is not a subclass of XML::XMetaL::Utilities::Filter::Base"
            unless $args{-filter}->isa('XML::XMetaL::Utilities::Filter::Base');
        $self = bless {
            _current_node => $args{-domnode} || croak("-domnode parameter missing or undefined"),
            _filter  => $args{-filter},
        }, ref($class) || $class;
        lock_keys(%$self, keys %$self);
    };
    croak $@ if $@;
    return $self;
}

sub _get_current_node {$_[0]->{_current_node}}
sub _set_current_node {$_[0]->{_current_node} = $_[1];}
sub _get_filter {$_[0]->{_filter}}

sub has_next {
    my ($self) = @_;
    return $self->_get_current_node() ? TRUE : FALSE;
}

sub next {
    my ($self) = @_;
    my $current_node = $self->_get_current_node();
    my $next_node = $self->_find_next_node($current_node);
    $self->_set_current_node($next_node);
    return $current_node;
}

sub _find_next_node {
    my ($self, $current_node) = @_;
    return undef unless $current_node;
    my $child_nodes;
    my $next_node;
    if ($current_node->hasChildNodes()) {
        $child_nodes = $current_node->{childNodes};
        $next_node = $child_nodes->item(0);
    } elsif ($current_node->{nextSibling}) {
        $next_node = $current_node->{nextSibling};
    } else {
        return undef;
    }
    my $filter = $self->_get_filter();
    if ($filter->accept($next_node)) {
        return $next_node;
    } else {
        return $self->_find_next_node($next_node);
    }    
}

1;

__END__
# Below is stub documentation for your module. You'd better edit it!

=head1 NAME

XML::XMetaL::Utilities::Iterator - Iterator class for XMetaL DOM nodes

=head1 SYNOPSIS

 use XML::XMetaL::Utilities::Iterator;
 use XML::XMetaL::Utilities::Filter::Element;

 my $dom_node = $xmetal->{ActiveDocument}->{documentElement};
 my $filter = XML::XMetaL::Utilities::Filter::Element->new();

 my $iterator = XML::XMetaL::Utilities::Iterator->new(-domnode => $dom_node,
                                                      -filter  => $filter);
 while ($iterator->has_next()) {
    $element_node = $iterator->next();
    # Do something with the element node
 };

=head1 DESCRIPTION

The C<XML::XMetaL::Utilities::Iterator> class is an iterator for
XMetaL DOM nodes.

The iterator uses a node filter to determine which nodes in a DOM node
tree to iterate over. See L<XML::XMetaL::Utilities::Filter::Base> for
more information about node filters.

=head2 Constructor and initialization

 use XML::XMetaL::Utilities::Iterator;
 my $iterator = XML::XMetaL::Utilities::Iterator->new(-domnode => $dom_node,
                                                      -filter  => $filter);

The constructor takes the following named parameters:

=over 4

=item C<-domnode>

The C<-domnode> parameter must be an XMetaL DOM node.

=item C<-filter>

The C<-filter> parameter must be a filter object. The filter object should
be a subclass of L<XML::XMetaL::Utilities::Filter::Base>.

=back

=head2 Class Methods

None.

=head2 Public Methods

=over 4

=item C<has_next>

 while ($iterator->has_next()) {
    ...
 };

The C<has_next> method checks if there are more nodes to be stepped
through by the iterator.

The method returns a true value if there are more nodes to iterate over,
false if there are not.

Note that in many cases, you can dispense with the C<has_next> method
and just do this:

 my $current_node;
 while ($current_node = $iterator->next()) {
    ...
 };

=item C<next>

 my $current_node = $iterator->next();

The C<next> method returns the next node to iterate over. If there are
no more nodes, the method returns C<undef>.

=back

=head2 Private Methods

None.

=head1 ENVIRONMENT

The Corel XMetaL XML editor must be installed.

=head1 BUGS

A lot, I am sure.

Please send bug reports to E<lt>henrik.martensson@bostream.nuE<gt>.


=head1 SEE ALSO

See L<XML::XMetaL>, L<XML::XMetaL::Filter::Base>.

=head1 AUTHOR

Henrik Martensson, E<lt>henrik.martensson@bostream.nuE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright 2003 by Henrik Martensson

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself. 

=cut
