# Generate a Erlang header with records

package hrl;

use strict;

# called at the start
sub hrl_init {
}

# called just before traversing the node tree
sub hrl_begin {
    print "%% Generated by the reporter.pl from TR*.xml\n\n\n";    
}

my $hrl_guard = "";

sub model_checks {
    my ($name, $node) = @_;
    $hrl_guard = $name;
    $hrl_guard =~ s/^(\w+):.*/$1/;

    my $path = $node->{path};  

    print "model: $name\n";
    print "hrl_guard: $hrl_guard\n";

    printf "-ifndef(_%s_HRL_).\n", $hrl_guard;
    printf "-define(_%s_HRL_, true).\n", $hrl_guard;
}

sub object_checks {
    my ($name, $node) = @_;
    my $path = $node->{path};  

    $name =~ s/\..*//;
    print "%% \@doc: $path\n";
    print "-record('$name',{ \n";

    my @nodes = @{$node->{nodes}}; 
    my $last = $nodes[-1];
    foreach my $child (@nodes) {        
        print "  ";
        parameter_checks($child);
        print ",\n" if $child != $last;
    }    

    print "\n}).\n\n";
}

sub type_check {
    my ($node) = @_;
    my $name = $node->{name};  
    my $type = $node->{type};
    my $value = $node->{value};

    if ($type =~ "dataType") {
        $type = $node->{syntax}->{ref};
    }

    if (defined $value) {
        print "'$name' = $value :: $type()";    
    } else {
        print "'$name' :: $type()";
    }

        # for my $key (keys $node->{syntax}) {
        #     print "$key, ";

}

sub include_check {
    my ($node) = @_;
    my $name = $node->{name};  
    $name =~ s/\..*//;
    my $array = defined $node->{numEntriesParameter};

    if ($array) {
        print "'$name'\t :: [\@$name\{\}]";
    } else {
        print "'$name'\t :: \@$name\{\}";
    }
}

sub parameter_checks {
    my ($node) = @_;

    my $object = ($node->{type} eq 'object');
    my $parameter = (defined $node->{syntax});

    type_check($node) if $parameter;
    include_check($node) if $object;    
}

sub hrl_node
{
    my ($node, $i, $hash) = @_;

    my $model = ($node->{type} eq 'model');
    my $object = ($node->{type} eq 'object');
    my $parameter = (defined $node->{syntax});

    my $name = $node->{name};

    model_checks($name, $node) if $model;
    object_checks($name, $node) if $object;

    # my $values = $node->{values};
    # my $syntax = $node->{syntax};


    # print "n $node->{name}\n";
    # print "p $node->{path}\n";
    # print "w $node->{writable}\n";
    # print "v $node->{value}\n";
    # print "cn $node->{children}\n";
    # print "t $node->{type}\n";
    # print "s $node->{syntax}\n";
    # print "s $node->{syntax}->{list}\n";
    # print "a $node->{access}\n";
}

# called for each node: after children
sub hrl_post {
    my ($node, $i, $hash) = @_;
}

# called at the end
sub hrl_end {
    printf "-endif. %% _%s_HRL_\n", $hrl_guard;
}


1;