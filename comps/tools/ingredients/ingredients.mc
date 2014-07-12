% #+-----------------------------------------+
% #|         Ingredients Setup tool          |
% #+-----------------------------------------+
%
% # Enter a new ingredient name or an old on to change
% # Select exiting active ingredients to be changed
% # List all ingredients at start
% # - Level 3 can create, update, reactivate
% # - Level 2 can create, update, reactivate
% # - Level 1 can read only

<%class>
    has 's' => (required => 1);
</%class>

<style>
#header { background-color: #DADADA; text-align:center; }
#tablebody { background-color: #DAFFDA; text-align:center; }
#centeredtext { text-align:center; }
#editlabel { text-align:right; background-color: white; }
#editdata { text-align:left; background-color: white; }
#tableedit { left:25%; float:center; width:50%; text-align:center; background-color: white; }
#access { text-align:center; background-color: white; }
#active { background-color: #DDFFDD; }
#inactive { background-color: #FFEEAA; }
</style>

% if ( $message ) {
    <div id='message'><% $message | H %></div></br>
% }

% #+------------------------------------------------+
% #|             Create a new ingredient            |
% #+------------------------------------------------+
% if ( $can_2 ) {
%   if ( defined $ingredient and scalar(@$ingredient) == 1 ) {
      <div align='center'>
          <a href='/home?s=ingredients'>back</a>
      </div>
      </br>
%     } else {
      <div align='center'>
        Create ingredient:&nbsp;
        <input name='new_ingredient' type='text' size='10' value='<% ( $args->{new_ingredient} || '' ) | H %>'>
        <input name='create_ingredient' type='submit' value='Create'>
      </div>
%   }
% }

% #+------------------------------------------------+
% #|                List ingredients                |
% #+------------------------------------------------+
% # List all ingredients
% if ( defined $ingredient and scalar @$ingredient > 1 ) {
    <div><table width='100%'>
%   # Table header
% if ( $can_2 ) {
     <tr id='header'><td>Select</td><td>Ingredient</td><td>Stock</td><td>Status</td><td>Creation Date</td><td>Last updated Date</td></tr>
% } else {
     <tr id='header'><td>Ingredient</td><td>Stock</td><td>Status</td><td>Creation Date</td><td>Last updated Date</td></tr>
% }
%    foreach my $row ( @$ingredient ) {
      <tr id='tablebody'>
%     my $style;
%     if ( $row->{status} eq 'Active' ) { $style = "active"; } else { $style = "inactive"; }
% if ( $can_2 ) {
      <td id='<% $style %>'><input name='selected_id' value="<% $row->{id} %>" type='submit'></td>
% }
      <td id='<% $style %>'><% $row->{name} %></td>
      <td id='<% $style %>'><% $row->{in_stock} %></td>
      <td id='<% $style %>'><% $row->{status} %></td>
      <td id='<% $style %>'><% $row->{creation_date} %></td>
      <td id='<% $style %>'><% $row->{last_updated_date} %></td>
     </tr>
%    }
   </table></div>

% #+------------------------------------------------+
% #|                Edit Ingredient                 |
% #+------------------------------------------------+
% # One was selected and will be shown to edit from level 1 users
% } elsif ( defined $ingredient and scalar @$ingredient == 1 ) {
%  $m->redirect('/home?s=ingredients') unless $can_2;
   <div align='center'><table id='tableedit'>
%  foreach my $row ( @$ingredient ) {
     <tr id='editlabel'><td><b>ingredient:&nbsp;</b></td><td id='editdata'><% $row->{name} %></td></tr>
      <input name='name' value='<% $row->{name} %>' type='hidden'>
      <input name='id' value='<% $row->{id} %>' type='hidden'>
     <tr id='editlabel'><td><b>Stock:&nbsp;</b></td><td id='editdata'><input name='in_stock' value="<% $row->{in_stock} %>"></td></tr>
     <tr id='editlabel'><td><b>Status:&nbsp;</b></td><td id='editdata'>
       <select name='status'>
%      foreach my $status ( qw/Active Inactive/ ) {
        <option value="<% $status %>" <% $status eq $row->{status} ? "selected" : '' %>><% $status %></option>
%      }
       </select>
      </td>
     </tr>
     <tr id='editlabel'><td><b>Created:&nbsp;</b></td><td id='editdata'><% $row->{creation_date} %></td></tr>
     <tr id='editlabel'><td><b>Last Updated:&nbsp;</b></td><td id='editdata'><% $row->{last_updated_date} %></td></tr>
%  }
   </table></div>

   <div></br></div>

   <div align='center'><table><tr><td></td><td><input type=submit name="Save" value="Save"></td><td></td></tr></table></div>
% }

% #+------------------------------------------------+
% #|                    INIT START                  |
% #+------------------------------------------------+
<%init>
    # Only users with level 1 or more are able to access this tool
    my $access = $m->session()->{user_access};
    my $can_1  = $access->can('ingredients',1);
    my $can_2  = $access->can('ingredients',2);
    my $can_3  = $access->can('ingredients',3);
    $m->redirect('/home') unless $can_1;

    my $message = '';

    my $args = $m->request_args();
    my $ingredient = get_ingredients();

    # for when we have a selected id, gather all access info level
    if ( defined $args and defined $args->{selected_id} and $args->{selected_id} =~ m/[0-9]/ ) {
        $ingredient = get_ingredient_by_id($args->{selected_id});
    }

    if ( defined $args and defined $args->{Save} ) {
        Icemaker::Database::DBS->new()->execute({
            db  => 'development',
            sql => qq{ UPDATE ingredient SET status = ?, name = ?, in_stock = ? WHERE id = ? },
            bind_values => [ $args->{status}, $args->{name}, $args->{in_stock}, $args->{id} ],
        });
        $ingredient = get_ingredients();
    }

    if ( defined $args and defined $args->{new_ingredient} and length($args->{new_ingredient}) and defined $args->{create_ingredient} ) {
        if ( $ingredient = get_ingredient_by_name($args->{new_ingredient}) ) {
        } else {
            Icemaker::Internal::Ingredient->create_ingredient({ name => $args->{new_ingredient} });
            $ingredient = get_ingredient_by_name($args->{new_ingredient});
        }
    }
</%init>

<%perl>
sub get_ingredients {
    return Icemaker::Database::DBS->new()->get_hasharray({
        db  => 'development',
        sql => qq{ SELECT * FROM ingredient WHERE status = 'Active' ORDER BY name ASC },
    });
}

sub get_ingredient_by_id {
    my $id = shift || return [];
    return Icemaker::Database::DBS->new()->get_hasharray({
        db  => 'development',
        sql => qq{ SELECT * FROM ingredient WHERE id = ? },
        bind_values => [ $id ],
    });
}

sub get_ingredient_by_name {
    my $name = shift || return [];
    return Icemaker::Database::DBS->new()->get_hasharray({
        db  => 'development',
        sql => qq{ SELECT * FROM ingredient WHERE name = ? },
        bind_values => [ $name ],
    });
}
</%perl>

