ActiveAdmin.register OrganizationsUsers do
  menu priority: 4, label: "Organization Memberships"

  permit_params :user_id, :organization_id, :role

  filter :user_id
  filter :organization_id
  filter :role, as: :select, collection: ["org-user", "org-admin"]
  filter :created_at

  index do
    selectable_column
    id_column
    column :user do |ou|
      link_to ou.user.email, admin_user_path(ou.user) if ou.user
    end
    column :organization do |ou|
      link_to ou.organization.organization_name, admin_organization_path(ou.organization) if ou.organization
    end
    column :role do |ou|
      status_tag ou.role || "member", class: ou.role == "org-admin" ? "primary" : "default"
    end
    column :created_at
    actions
  end

  show do
    attributes_table do
      row :id
      row :user do |ou|
        link_to ou.user.email, admin_user_path(ou.user) if ou.user
      end
      row :organization do |ou|
        link_to ou.organization.organization_name, admin_organization_path(ou.organization) if ou.organization
      end
      row :role
      row :created_at
      row :updated_at
    end
  end

  form do |f|
    f.inputs "Membership Details" do
      f.input :user, as: :select, collection: User.all.map { |u| ["#{u.name} (#{u.email})", u.id] }, include_blank: false
      f.input :organization, as: :select, collection: Organization.all.map { |o| [o.organization_name, o.id] }, include_blank: false
      f.input :role, as: :select, collection: ["org-user", "org-admin"], include_blank: "member"
    end

    f.actions
  end

  controller do
    def csv_filename
      "OrganizationMemberships.csv"
    end
  end

  csv do
    column :id
    column "User Email" do |ou|
      ou.user&.email
    end
    column "Organization Name" do |ou|
      ou.organization&.organization_name
    end
    column :role
    column :created_at
  end

  batch_action :promote_to_admin do |ids|
    batch_action_collection.find(ids).each do |ou|
      ou.update(role: "org-admin")
    end
    redirect_to collection_path, notice: "Users promoted to organization admins."
  end

  batch_action :demote_to_user do |ids|
    batch_action_collection.find(ids).each do |ou|
      ou.update(role: "org-user")
    end
    redirect_to collection_path, notice: "Users demoted to organization users."
  end
end
