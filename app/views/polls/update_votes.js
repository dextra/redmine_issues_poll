$("#view_votes_<%=@user.id%>").html("<%= @votes %>");
<% if @success %>
  toggleForm("<%= @user.id %>");
  alert("<%= t(:assignment_successful) %>");
<% else %>
  alert("<%= t(:invalid_votes) %>");
<% end %>