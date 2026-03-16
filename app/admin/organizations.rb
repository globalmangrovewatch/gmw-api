ActiveAdmin.register Organization do
  menu priority: 3, label: "Organizations"

  permit_params :organization_name, user_ids: []

  filter :organization_name
  filter :created_at

  index do
    selectable_column
    id_column
    column :organization_name
    column "Members" do |org|
      org.users.count
    end
    column :created_at
    actions
  end

  show do
    attributes_table do
      row :id
      row :organization_name
      row :created_at
      row :updated_at
    end

    panel "Members" do
      table_for organization.users do
        column :id
        column :email
        column :name
        column "Role" do |user|
          org_user = OrganizationsUsers.find_by(user_id: user.id, organization_id: organization.id)
          status_tag org_user&.role || "member", class: org_user&.role == "org-admin" ? "primary" : "default"
        end
        column :last_sign_in_at
        column "Actions" do |user|
          link_to "View", admin_user_path(user), class: "member_link"
        end
      end
    end

    panel "Landscapes" do
      table_for organization.landscapes do
        column :id
        column :name
      end
    end
  end

  form do |f|
    f.inputs "Organization Details" do
      f.input :organization_name
    end

    f.inputs "Members" do
      f.input :users, as: :check_boxes, collection: User.all.map { |u| ["#{u.name} (#{u.email})", u.id] }
    end

    f.actions
  end

  controller do
    def csv_filename
      "Organizations.csv"
    end
  end

  csv do
    column :id
    column :organization_name
    column :created_at
    column :updated_at
    column "Total Members" do |org|
      org.users.count
    end
  end
end
