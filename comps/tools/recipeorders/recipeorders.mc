% #+-----------------------------------------+
% #|          Recipe Ordering tool           |
% #+-----------------------------------------+
%
% # - Select an existing order from the list to edit
% # - Create a new order by selecting first the customer ordering it
% # - Add recipes from drop down and enter amounts for each package size
% # - Remove added recipes
% # - Save -> redirect to list
%
% # - Level 3 can create, update
% # - Level 2 can create, update
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
#recipes { text-align:center; background-color: white; }
#saved      { background-color: #DDGGDD; text-align:center; }
#cancelled  { background-color: #DEDEDE; text-align:center; }
#queued     { background-color: #FFFFAA; text-align:center; }
#inprogress { background-color: #AAFFFF; text-align:center; }
#pending    { background-color: #FFCCAA; text-align:center; }
#completed  { background-color: #00FF00; text-align:center; }
#closed     { background-color: #00AAFF; text-align:center; }
</style>

% if ( $message ) {
    <div id='message'><% $message | H %></div></br>
% }

% #+------------------------------------------------+
% #|               Create a new order               |
% #+------------------------------------------------+
% if ( $can_2 ) {
%   if ( defined $order and scalar(@$order) == 1 ) {
      <div align='center'>
        <a href='/home?s=recipeorders'>back</a>
      </div>
      </br>
%   } else {
      <div align='center'>
        Select customer:&nbsp;
        <td>
          <select name="customer_id">
%           my $all_customers = get_all_customers();
%           foreach my $h ( @$all_customers ) {
              <option value="<% $h->{id} %>"><% $h->{name} %></option>
%           }
          </select>
        </td>
        <td>
            <input name='create_order' type='submit' value='Create Order'>
        </td>
      </div>
%   }
% }

% #+------------------------------------------------+
% #|                  List orders                   |
% #+------------------------------------------------+
% # List all orders
% if ( defined $order and scalar @$order > 1 ) {
    <div>
      <table width='100%'>
% #     Table header
        <tr id='header'>
%         if ( $can_2 ) {
            <td>Select</td>
%         }
          <td>Customer</td>
          <td>Recipes</td>
          <td>Qty</td>
          <td>LT</td>
          <td>Pkgs</td>
          <td>Deadline</td>
          <td>Status</td>
          <td>Created</td>
          <td>Last updated</td>
        </tr>
%       foreach my $row ( @$order ) {
          <tr id='tablebody'>
%           my $style = $row->{status};
%           $style =~ s/ //gi;
%           if ( $can_2 ) {
              <td id='<% $style %>'>
                <input name='selected_id' value="<% $row->{id} %>" type='submit'>
              </td>
%           }
            <td id='<% $style %>'><% $row->{name} | H %></td>
%           my $recipes_name;
%           my $recipes_qty;
%           my $recipes_tllt;
%           my $recipes_pkgs;
%           my $recipes_ddln;
%           my $recipes_stts;
%           my $recipes = get_ordered_recipes($row->{id});
%           foreach my $h ( @$recipes ) {
%             push @$recipes_name, $h->{name};
%             push @$recipes_qty,  $h->{quantity};
%             push @$recipes_tllt, $h->{totallt};
%             push @$recipes_pkgs, $h->{packages};
%             push @$recipes_ddln, $h->{deadline};
%             push @$recipes_stts, $h->{status};
%           }
%           if ( defined $recipes and scalar @$recipes ) {
              <td id='<% $style %>'><% join("<br>", @$recipes_name) %></td>
              <td id='<% $style %>'><% join("<br>", @$recipes_qty) %></td>
              <td id='<% $style %>'><% join("<br>", @$recipes_tllt) %></td>
              <td id='<% $style %>'><% join("<br>", @$recipes_pkgs) %></td>
              <td id='<% $style %>'><% join("<br>", @$recipes_ddln) %></td>
              <td id='<% $style %>'><% join("<br>", @$recipes_stts) %></td>
              <td id='<% $style %>'><% $row->{creation_date} %></td>
              <td id='<% $style %>'><% $row->{last_updated_date} %></td>
%           } else {
              <td id='<% $style %>'>-</td>
              <td id='<% $style %>'>-</td>
              <td id='<% $style %>'>-</td>
              <td id='<% $style %>'>-</td>
              <td id='<% $style %>'>-</td>
              <td id='<% $style %>'>-</td>
              <td id='<% $style %>'><% $row->{creation_date} %></td>
              <td id='<% $style %>'><% $row->{last_updated_date} %></td>
%           }
          </tr>
%       }
      </table>
    </div>

% #+------------------------------------------------+
% #|                   Edit order                   |
% #+------------------------------------------------+
% # One was selected and will be shown to edit from level 1 users
% } elsif ( defined $order and scalar @$order == 1 ) {
%   $m->redirect('/home?s=recipeorders') unless $can_2;
    <div align='center'>
      <table id='tableedit'>
%       my $row = $order->[0];
        <tr id='editlabel'>
          <td><b>order ID:&nbsp;</b></td>
          <td id='editdata'><% $row->{id} %></td>
        </tr>
        <input name='id' value='<% $row->{id} %>' type='hidden'>
        <tr id='editlabel'>
          <td><b>customer:&nbsp;</b></td>
          <td id='editdata'><% $row->{name} %></td>
        </tr>
        <input name='customer_id' value='<% $row->{customer_id} %>' type='hidden'>
        <tr id='editlabel'>
          <td><b>Status:&nbsp;</b></td>
          <td id='editdata'>
            <select name='status'>
%             foreach my $status ( get_order_status() ) {
                <option value="<% $status %>" <% $status eq $row->{status} ? "selected" : '' %>><% $status %></option>
%             }
            </select>
          </td>
        </tr>
        <tr id='editlabel'>
          <td><b>Created:&nbsp;</b></td>
          <td id='editdata'><% $row->{creation_date} %></td>
        </tr>
        <tr id='editlabel'>
          <td><b>Last Updated:&nbsp;</b></td>
          <td id='editdata'><% $row->{last_updated_date} %></td>
        </tr>
      </table>
    </div>

    <div></br></div>

%   # Add / remove / edit recipes with their packages section
    <div>
      <table width='80%' align='center'>
%       my $header;
%       foreach my $p ( @{get_all_packages()} ) {
%         $header .= "<td>$p->{name}</td>";
%       }
        <tr id='header'>
          <td>Recipe's name</td><% $header %>
        </tr>
% #     List recipes attached to this order
%       my $recipe_ids;
%       my $recipes = get_ordered_recipes($row->{id});
%       foreach my $h ( @$recipes ) {
%         push @$recipe_ids, $h->{id};
          <tr id='recipes'>
            <td><% $h->{name} %></td>
%           my $tubs = get_ordered_tubs($row->{id},$h->{recipe_id});
%           foreach my $u ( @{get_all_packages()} ) {
%             if ( defined $args and defined $args->{edit_recipe} and $h->{recipe_id} eq $args->{edit_recipe} ) {
                <td><input name="add_package_<% $u->{id} %>" type='text' size='3' value="<% $tubs->{$u->{name}} || 0 %>"></td>
%             } else {
                <td><input type='hidden' name="add_package_<% $u->{id} %>" value="<% $tubs->{$u->{name}} || 0 %>"><% $tubs->{$u->{name}} || 0 %></td>
%             }
%           }
%           if ( defined $args and defined $args->{edit_recipe} and $args->{edit_recipe} eq $h->{recipe_id} ) {
              <td><input type='submit' name='update' value='update'></td>
              <input type='hidden' name='add_recipe' value="<% $h->{recipe_id} %>"></td>
              <input type='hidden' name='id' value="<% $row->{id} %>"></td>
%           } else {
              <td><a href="/home?s=recipeorders&edit_recipe=<% $h->{recipe_id} %>&id=<% $row->{id} %>">edit</a></td>
              <td><a href="/home?s=recipeorders&remove_recipe=<% $h->{recipe_id} %>&id=<% $row->{id} %>">remove</a></td>
%           }
          </tr>
%      }
%      if ( defined $args and defined $args->{edit_recipe} ) {
%          # do not show add new options until edit is finished.
%      } else {
% #      Drop down of all other recipes available to be added to this order
%        my $all_other_recipes = get_all_other_recipes($row->{id});
%        if ( $all_other_recipes ) {
           <tr id='recipes'>
             <td><select name="add_recipe">
%              foreach my $h ( @$all_other_recipes ) {
                 <option value="<% $h->{id} %>"><% $h->{name} %></option>
%              }
             </td>
%            foreach my $u ( @{get_all_packages()} ) {
               <td><input name="add_package_<% $u->{id} %>" type='text' size='3'></td>
%            }
             <td><input type='submit' name='add' value='add'></td>
           </tr>
%        }
%      }
     </table>
   </div>
   </br>

   <div align='center'>
     <table>
       <tr>
         <td></td>
         <td><input type=submit name="Save" value="Save"></td>
         <td></td>
       </tr>
     </table>
   </div>
% }
% print "<pre>" . ( Data::Dumper::Dumper { args => $args } ) . "</pre>";
% #+------------------------------------------------+
% #|                    INIT START                  |
% #+------------------------------------------------+
<%init>
    # Only users with level 1 or more are able to access this tool
    my $access = $m->session()->{user_access};
    my $can_1  = $access->can('recipeorders',1);
    my $can_2  = $access->can('recipeorders',2);
    my $can_3  = $access->can('recipeorders',3);
    $m->redirect('/home') unless $can_1;

    my $args = $m->request_args();
    my $message = $args->{message} || '';
    my $order = get_orders();

    if ( defined $args ) {
        if ( defined $args->{selected_id} ) {
            $order = get_order($args->{selected_id});
        }

        # Save Order data Status and return to list
        if ( defined $args->{Save} ) {
            save_order($args);
            $order = get_orders();

        # Save added packages and return to this order edit
        } elsif ( defined $args->{add} or defined $args->{update} ) {
            add_recipe($args);
            $order = get_order($args->{id});

        # Nothing to save yet, just allow to be edited
        } elsif ( defined $args->{edit_recipe} ) {
            $order = get_order($args->{id});

        # Save removed packages and return to this order edit
        } elsif ( defined $args->{remove_recipe} ) {
            remove_recipe($args);
            $order = get_order($args->{id});
        } elsif ( defined $args->{create_order} and defined $args->{customer_id} ) {
            $order = get_order(create_order($args));
        }
    }
</%init>

<%perl>
sub create_order {
    my $args = shift || die "No args supplied";
    my $customer_id = $args->{customer_id} || die "No customer_id selected";

    Icemaker::Database::DBS->new()->execute({
        db  => 'development',
        sql => qq{ INSERT INTO orders (customer_id) VALUES(?) },
        bind_values => [ $customer_id ],
    });

    return Icemaker::Database::DBS->new()->get_hash({
        db  => 'development',
        sql => qq{ SELECT id FROM orders WHERE customer_id = ? ORDER BY id DESC LIMIT 1 },
        bind_values => [ $customer_id ],
    })->{id};
}

sub get_ordered_recipes {
    my $order_id = shift || die "No order id supplied";
    return Icemaker::Database::DBS->new()->get_hasharray({
        db  => 'development',
        sql => qq{
            SELECT ore.recipe_id, r.name, 
                TRUNCATE(SUM(IF(p.units = 'lt', p.size*quantity, p.size*quantity/1000)),3) AS totallt, 
                TRUNCATE(SUM(IF(p.units = 'lt', p.size*quantity, p.size*quantity/1000))/r.final_size,3) AS quantity,
                SUM(ort.quantity) AS packages, 
                now() as deadline, 
                ore.status 
            FROM orders o JOIN order_recipe ore 
              ON ore.order_id = o.id 
            JOIN order_recipe_tub ort 
              ON ort.order_recipe_id = ore.id 
            JOIN package p 
              ON p.id = ort.package_id 
            JOIN recipe r 
              ON r.id = ore.recipe_id 
            WHERE o.id = ?
            GROUP BY recipe_id
            ORDER BY ore.id ASC
        },
        bind_values => [ $order_id ],
    }) || [];
}

sub get_ordered_tubs {
    my $order_id  = shift || die "No order id supplied";
    my $recipe_id = shift || die "No recipe id supplied";
    my $ha = Icemaker::Database::DBS->new()->get_hasharray({
        db  => 'development',
        sql => qq{ 
            SELECT p.id, p.name, p.size, ort.quantity 
            FROM orders o 
            JOIN order_recipe ore 
              ON ore.order_id = o.id 
            JOIN order_recipe_tub ort 
              ON ort.order_recipe_id = ore.id 
            JOIN package p 
              ON p.id = ort.package_id 
            WHERE o.id = ? 
                AND ore.recipe_id = ?
        },
        bind_values => [ $order_id, $recipe_id ],
    });
    my $res;
    foreach my $h ( @$ha ) {
        $res->{$h->{name}} = $h->{quantity};
    }
    return $res;
}

sub get_recipes {
    return Icemaker::Database::DBS->new()->get_hasharray({
        db  => 'development',
        sql => qq{ SELECT * FROM recipe },
    });
}

sub get_all_other_recipes {
    my $order_id = shift || die "No order id supplied";
    return Icemaker::Database::DBS->new()->get_hasharray({
        db  => 'development',
        sql => qq{ 
            SELECT * FROM recipe 
            WHERE id NOT IN(
                SELECT recipe_id FROM orders o 
                JOIN order_recipe ore ON ore.order_id = o.id
                WHERE o.id = ?
            )
        },
        bind_values => [ $order_id ],
    });
}

sub get_all_packages {
    return Icemaker::Database::DBS->new()->get_hasharray({
        db  => 'development',
        sql => qq{ SELECT * FROM package WHERE status = 'Active' },
    });
}

sub get_all_customers {
    return Icemaker::Database::DBS->new()->get_hasharray({
        db  => 'development',
        sql => qq{ SELECT id, name FROM customer WHERE status = 'Active' ORDER BY name ASC },
    });
}

sub save_order {
    my $args        = shift || die "No args supplied";
    my $customer_id = $args->{customer_id} || die "No customer_id defined";
    my $status      = $args->{status} || die "No status defined";
    my $id          = $args->{id} || die "No order id defined";

    Icemaker::Database::DBS->new()->execute({
        db  => 'development',
        sql => qq{ UPDATE orders SET customer_id = ?, status  =? WHERE id = ? },
        bind_values => [ $customer_id, $status, $id ],
    });
}

sub remove_recipe {
    my $args = shift || die "No args supplied";
    my $order_id = $args->{id} || die "No order id supplied";
    my $recipe_id = $args->{remove_recipe} || die "No recipe id supplied";

    my $order_recipe_id = Icemaker::Database::DBS->new()->get_hash({
        db  => 'development',
        sql => qq{ 
            SELECT id FROM order_recipe WHERE order_id = ? AND recipe_id = ?
        },
        bind_values => [ $order_id, $recipe_id ],
    })->{id};

    Icemaker::Database::DBS->new()->execute({
        db  => 'development',
        sql => qq{ 
            DELETE FROM order_recipe WHERE order_id = ? AND recipe_id = ?
        },
        bind_values => [ $order_id, $recipe_id ],
    });

    Icemaker::Database::DBS->new()->execute({
        db  => 'development',
        sql => qq{ 
            DELETE FROM order_recipe_tub WHERE order_recipe_id = ?
        },
        bind_values => [ $order_recipe_id ],
    });
}

sub add_recipe {
    my $args      = shift || die "No args supplied";
    my $order_id  = $args->{id} || die "No order id supplied";
    my $recipe_id = $args->{add_recipe} || die "No recipe id supplied";

    my %packages;
    foreach my $k ( %$args ) {
        next unless $k  =~ m/^add_package_/;
        my $package_id = $k;
        $package_id =~ s/^add_package_//gi;
        my $quantity = $args->{$k};
        if ( defined $quantity and length($quantity) ) {
            $packages{$package_id} = $quantity;
        }
    }
    my $order_recipe = Icemaker::Database::DBS->new()->get_hash({
        db  => 'development',
        sql => qq{
            SELECT id
            FROM order_recipe
            WHERE order_id = ?
                AND recipe_id = ?
        },
        bind_values => [ $order_id, $recipe_id ],
    });

    if ( defined $order_recipe and defined $order_recipe->{id} ) {
        Icemaker::Database::DBS->new()->execute({
            db  => 'development',
            sql => qq{ UPDATE order_recipe 
                SET order_id = ?, recipe_id = ?
                WHERE id = ? },
            bind_values => [ $order_id, $recipe_id, $order_recipe->{id} ],
        });
    } else {
        Icemaker::Database::DBS->new()->execute({
            db  => 'development',
            sql => qq{ INSERT IGNORE INTO order_recipe 
                (order_id,recipe_id) VALUES(?,?) },
            bind_values => [ $order_id, $recipe_id ],
        });
    }

    my $order_recipe_id = Icemaker::Database::DBS->new()->get_hash({
        db  => 'development',
        sql => qq{ 
            SELECT id 
            FROM order_recipe 
            WHERE order_id = ?
                AND recipe_id = ?
        },
        bind_values => [ $order_id, $recipe_id ],
    })->{id};

    foreach my $package_id ( keys %packages ) {
        Icemaker::Database::DBS->new()->execute({
            db  => 'development',
            sql => qq{ INSERT IGNORE INTO order_recipe_tub
                (order_recipe_id,package_id,quantity) VALUES(?,?,?) },
            bind_values => [ $order_recipe_id, $package_id, $packages{$package_id} ],
        });
    }

}

sub get_orders {
    return Icemaker::Database::DBS->new()->get_hasharray({
        db  => 'development',
        sql => qq{ 
            SELECT o.*, c.name 
            FROM orders o 
            LEFT JOIN customer c 
              ON c.id = o.customer_id 
            ORDER BY o.id ASC 
        },
    });
}

sub get_order {
    my $id = shift || return [];
    return Icemaker::Database::DBS->new()->get_hasharray({
        db  => 'development',
        sql => qq{ SELECT o.*, c.name FROM orders o LEFT JOIN customer c ON c.id = o.customer_id WHERE o.id = ? },
        bind_values => [ $id ],
    });
}

sub get_order_status {
    return ('saved','cancelled','queued','in progress','pending','completed','closed');
}

</%perl>

