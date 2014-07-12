% #+-----------------------------------------+
% #|           Recipes Setup tool            |
% #+-----------------------------------------+
%
% # Enter a new recipe name or an old on to change
% # Select exiting active recipes to be changed
% # List all recipes at start
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
#ingredients { text-align:center; background-color: white; }
#active { background-color: #DDFFDD; }
#inactive { background-color: #FFEEAA; }
</style>

% if ( $message ) {
    <div id='message'><% $message | H %></div></br>
% }

% #+------------------------------------------------+
% #|               Create a new recipe              |
% #+------------------------------------------------+
% if ( $can_2 ) {
%   if ( defined $recipe and scalar(@$recipe) == 1 ) {
      <div align='center'>
          <a href='/home?s=recipes'>back</a>
      </div>
      </br>
%     } else {
      <div align='center'>
        Create recipe:&nbsp;
        <input name='new_recipe' type='text' size='10' value='<% ( $args->{new_recipe} || '' ) | H %>'>
        <input name='create_recipe' type='submit' value='Create'>
      </div>
%   }
% }

% #+------------------------------------------------+
% #|                  List recipes                  |
% #+------------------------------------------------+
% # List all recipes
% if ( defined $recipe and scalar @$recipe > 1 ) {
    <div><table width='100%'>
%   # Table header
% if ( $can_2 ) {
     <tr id='header'><td>Select</td><td>Recipe</td><td>Pasteurised</td><td>Duration</td><td>Final Size LT</td><td>Ingredients</td><td>Status</td><td>Creation Date</td><td>Last updated Date</td></tr>
% } else {
     <tr id='header'><td>Recipe</td><td>Pasteurised</td><td>Duration</td><td>Final Size LT</td><td>Ingredients</td><td>Status</td><td>Creation Date</td><td>Last updated Date</td></tr>
% }
%    foreach my $row ( @$recipe ) {
      <tr id='tablebody'>
%     my $style;
%     if ( $row->{status} eq 'Active' ) { $style = "active"; } else { $style = "inactive"; }
% if ( $can_2 ) {
      <td id='<% $style %>'><input name='selected_id' value="<% $row->{id} %>" type='submit'></td>
% }
      <td id='<% $style %>'><% $row->{name} %></td>
      <td id='<% $style %>'><% $row->{pasteurised} %></td>
      <td id='<% $style %>'><% $row->{duration} %></td>
      <td id='<% $style %>'><% $row->{final_size} %></td>
%     my $ingredients_str = '<pre>';
%     foreach my $h ( @{get_ingredients($row->{id})} ) {
%         $ingredients_str .= "- $h->{quantity} $h->{units} $h->{name}\n";
%     }
%     $ingredients_str .= "</pre>";
      <td id='<% $style %>' align='left'><% $ingredients_str %></td>
      <td id='<% $style %>'><% $row->{status} %></td>
      <td id='<% $style %>'><% $row->{creation_date} %></td>
      <td id='<% $style %>'><% $row->{last_updated_date} %></td>
     </tr>
%    }
   </table></div>

% #+------------------------------------------------+
% #|                  Edit recipe                   |
% #+------------------------------------------------+
% # One was selected and will be shown to edit from level 1 users
% } elsif ( defined $recipe and scalar @$recipe == 1 ) {
%   $m->redirect('/home?s=recipes') unless $can_2;
    <div align='center'><table id='tableedit'>
%   my $row = $recipe->[0];
    <tr id='editlabel'><td><b>Recipe:&nbsp;</b></td><td id='editdata'><% $row->{name} %></td></tr>
     <input name='name' value='<% $row->{name} %>' type='hidden'>
     <input name='id' value='<% $row->{id} %>' type='hidden'>
    <tr id='editlabel'><td><b>Pasteurised:&nbsp;</b></td><td id='editdata'><input name='pasteurised' value="<% $row->{pasteurised} %>"></td></tr>
    <tr id='editlabel'><td><b>Duration:&nbsp;</b></td><td id='editdata'><input name='duration' value="<% $row->{duration} %>"></td></tr>
    <tr id='editlabel'><td><b>Final Size (lt):&nbsp;</b></td><td id='editdata'><input name='final_size' value="<% $row->{final_size} %>"></td></tr>
    <tr id='editlabel'><td><b>Notes:&nbsp;</b></td><td id='editdata'><textarea name='notes' rows=3 cloumns=10><% $row->{notes} | H %></textarea></td></tr>
    <tr id='editlabel'><td><b>Status:&nbsp;</b></td><td id='editdata'>
     <select name='status'>
%    foreach my $status ( qw/Active Inactive/ ) {
      <option value="<% $status %>" <% $status eq $row->{status} ? "selected" : '' %>><% $status %></option>
%    }
     </select>
     </td>
    </tr>
   <tr id='editlabel'><td><b>Created:&nbsp;</b></td><td id='editdata'><% $row->{creation_date} %></td></tr>
   <tr id='editlabel'><td><b>Last Updated:&nbsp;</b></td><td id='editdata'><% $row->{last_updated_date} %></td></tr>
   </table></div>

   <div></br></div>

%  # Add / remove added ingredients
   <div><table width='40%' align='center'>
    <tr id='header'><td>Ingredient's name</td><td>Qty</td><td>Units</td></tr>
% # List ingredients attached to this recipe
%   my $ingredient_ids;
%   foreach my $h ( @{get_ingredients($row->{id})} ) {
%     push @$ingredient_ids, $h->{id};
      <tr id='ingredients'>
%     if ( defined $h->{name} ) {
        <td><% $h->{name} %></td><td><% $h->{quantity} %></td><td><% $h->{units} %></td><td><a href="/home?s=recipes&remove_ingredient=<% $h->{id} %>&id=<% $row->{id} %>">remove</a></td>
%     }
      </tr>
%   }
% # Drop down of all other ingredients available to be added to this recipe
    <tr id='ingredients'>
     <td><select name="add_ingredient">
%    my $all_other_ingredients = get_all_other_ingredients($ingredient_ids);
%    foreach my $h ( @$all_other_ingredients ) {
       <option value="<% $h->{id} %>"><% $h->{name} %></option>
%    }
     </td>
     <td><input name="add_quantity" type='text' value='0.00'></td>
     <td><select name="add_units">
%    foreach my $u ( qw/kg g lt box/ ) {
       <option value="<% $u %>"><% $u %></option>
%    }
     </select></td>
    <td><input type='submit' name='add' value='add'></td>
   </tr>
   </table>
  </div>
  </br>

   <div align='center'><table><tr><td></td><td><input type=submit name="Save" value="Save"></td><td></td></tr></table></div>
% }
% #+------------------------------------------------+
% #|                    INIT START                  |
% #+------------------------------------------------+
<%init>
    # Only users with level 1 or more are able to access this tool
    my $access = $m->session()->{user_access};
    my $can_1  = $access->can('recipes',1);
    my $can_2  = $access->can('recipes',2);
    my $can_3  = $access->can('recipes',3);
    $m->redirect('/home') unless $can_1;

    my $args = $m->request_args();
    my $message = $args->{message} || '';
    my $recipe = get_recipes();

    # for when we have a selected id, gather all access info level
    if ( defined $args and defined $args->{selected_id} and $args->{selected_id} =~ m/[0-9]/ ) {
        $recipe = get_recipe_by_id($args->{selected_id});
    }

    if ( defined $args and defined $args->{Save} ) {
        Icemaker::Database::DBS->new()->execute({
            db  => 'development',
            sql => qq{ UPDATE recipe SET notes = ?, status = ?, name = ?, pasteurised = ?, duration = ? , final_size = ? WHERE id = ? },
            bind_values => [ $args->{notes}, $args->{status}, $args->{name}, $args->{pasteurised}, $args->{duration}, $args->{final_size}, $args->{id} ],
        });
        $recipe = get_recipes();
    }

    if ( defined $args and defined $args->{new_recipe} and length($args->{new_recipe}) and defined $args->{create_recipe} ) {
        if ( $recipe = get_recipe_by_name($args->{new_recipe}) ) {
        } else {
            Icemaker::Internal::Recipe->create_recipe({ name => $args->{new_recipe} });
            $recipe = get_recipe_by_name($args->{new_recipe});
        }
    }

    if ( defined $args and defined $args->{add_ingredient} and not defined $args->{Save}) {
        add_ingredient($args);
        $m->redirect('/home?s=recipes&selected_id='.$args->{id});
    }
    if ( defined $args and defined $args->{remove_ingredient} ) {
        remove_ingredient($args->{remove_ingredient},$args->{id});
        $m->redirect('/home?s=recipes&selected_id='.$args->{id});
    }
</%init>

<%perl>
sub remove_ingredient {
    my $ingred_id = shift || return "No ingredient supplied";
    my $recipe_id = shift || return "No recipe supplied";
    Icemaker::Database::DBS->new()->execute({
        db  => 'development',
        sql => qq{ DELETE FROM recipe_ingredient WHERE recipe_id = ? AND ingredient_id = ? },
        bind_values => [$recipe_id, $ingred_id],
    });
}
sub add_ingredient {
    my $args = shift || return "No arguments supplied";
    my $ingred_id = $args->{add_ingredient} || return "No ingredient supplied";
    my $recipe_id = $args->{id} || return "No recipe supplied";
    my $quantity  = $args->{add_quantity} || return "No quantity supplied";
    my $units     = $args->{add_units} || return "No unit supplied";
    Icemaker::Database::DBS->new()->execute({
        db  => 'development',
        sql => qq{ INSERT IGNORE INTO recipe_ingredient (recipe_id,ingredient_id,quantity,units) VALUES(?,?,?,?) },
        bind_values => [$recipe_id, $ingred_id, $quantity, $units],
    });
}

sub get_recipes {
    return Icemaker::Database::DBS->new()->get_hasharray({
        db  => 'development',
        sql => qq{ SELECT * FROM recipe WHERE status = 'Active' ORDER BY name ASC },
    });
}

sub get_recipe_by_id {
    my $id = shift || return [];
    return Icemaker::Database::DBS->new()->get_hasharray({
        db  => 'development',
        sql => qq{ SELECT * FROM recipe WHERE id = ? },
        bind_values => [ $id ],
    });
}

sub get_recipe_by_name {
    my $name = shift || return [];
    return Icemaker::Database::DBS->new()->get_hasharray({
        db  => 'development',
        sql => qq{ SELECT * FROM recipe WHERE name = ? },
        bind_values => [ $name ],
    });
}

sub get_all_ingredients {
    return Icemaker::Database::DBS->new()->get_hasharray({
        db  => 'development',
        sql => qq{ SELECT * FROM ingredient ORDER BY name ASC },
    });
}

sub get_all_other_ingredients {
    my $used_ids = shift;
    my $where;
    my $bind;
    if ( defined $used_ids and ref($used_ids) eq 'ARRAY' ) {
        $where = "WHERE id NOT IN(??)";
        $bind = $used_ids;
    } else {
        $where = '';
        $bind = '';
    }
    return Icemaker::Database::DBS->new()->get_hasharray({
        db  => 'development',
        sql => qq{ 
            SELECT id, name 
            FROM ingredient
            $where
            ORDER BY name ASC
        },
        bind_values => [ $bind ],
    });
}

sub get_ingredients {
    my $recipe = shift || return [];
    return Icemaker::Database::DBS->new()->get_hasharray({
        db  => 'development',
        sql => qq{ 
            SELECT i.id, i.name, ri.quantity, ri.units 
            FROM recipe_ingredient ri 
            JOIN ingredient i 
                ON i.id = ri.ingredient_id 
            WHERE recipe_id = ?
                AND i.status = 'Active' 
        },
        bind_values => [ $recipe ],
    }) || [];
}
</%perl>

