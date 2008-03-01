module ProjectsHelper
  def empty_projects_content(&block)
    yield if @projects.empty?
  end
  
  def project_audit_image(project)
    link_to image_tag("xml.gif"), audits_project_path(project)
  end
  
  def project_dashboard_link(project)
    link_to project.name, project_dashboard_path(project)
  end
  
  def link_to_delete_project(project)
    link_to "Delete", project_path(project), :method => :delete, :confirm => "Are you sure you want to delete?\r\nAll associated data will also be deleted. This action can not be undone."
  end

  def link_to_remove_user(user)
    link_to "Remove From Project", remove_from_project_project_user_path(@project, user), :method => :put
  end

  def link_to_add_users
    link_to_remote("Add Users to Project", :url => add_users_project_path(@project), :method => :get)
  end
end