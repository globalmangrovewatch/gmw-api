class V2::SitesController < MrttApiController
    def index
        select_clause = "sites.*, greatest(max(registration_intervention_answers.updated_at), max(monitoring_answers.updated_at)) as section_last_updated"

        # admin can list all sites record
        # org member can only list sites that belongs to landscapes 
        #   that is associated to the org they are member of
        @sites = current_user.is_admin ? 
            (
                Site.left_joins(:landscape, :registration_intervention_answers, :monitoring_answers)
                    .select(select_clause).group(:id)
            ) :
            (
                organization_ids = current_user.organization_ids
                landscape_ids = Landscape.joins(:organizations)
                                    .select("landscapes_organizations.*")
                                    .where("organization_id in (%s)" % (organization_ids + [0]).join(","))
                                    .map { |i| [i.landscape_id] }
                @sites = Site.left_joins(:landscape, :registration_intervention_answers, :monitoring_answers)
                    .select(select_clause)
                    .group(:id, "landscapes.id")
                    .where("landscape_id in (%s)" % (landscape_ids + [0]).join(","))
            )
    end

    def show
        @site = Site.find(params[:id])
        landscape = @site.landscape
        organization_ids = landscape.organization_ids

        # admin can show any site record
        # org member can only show site that belongs to landscape
        #   that is associated to the org they are member of
        if not (current_user.is_admin || current_user.is_member_of_any(organization_ids))
            insufficient_privilege && return
        end
    end

    def create
        landscape_id = params[:landscape_id]
        landscape = Landscape.find(landscape_id)
        organization_ids = landscape.organization_ids

        # admin can create any site record
        # org member can only create site that belongs to landscape
        #   that is associated to the org they are member of
        if not (current_user.is_admin || current_user.is_member_of_any(organization_ids))
            insufficient_privilege && return
        end
        @site = Site.create!(site_params)
    end

    def update
        landscape_id = params[:landscape_id]
        landscape = Landscape.find(landscape_id)
        organization_ids = landscape.organization_ids

        # admin can update any site record
        # org member can only update site that belongs to landscape
        #   that is associated to the org they are member of
        if not (current_user.is_admin || current_user.is_member_of_any(organization_ids))
            insufficient_privilege && return
        end
        @site = Site.find(site_params[:id])
        @site.update!(site_params)
    end

    def destroy
        landscape_id = params[:landscape_id]
        landscape = Landscape.find(landscape_id)
        organization_ids = landscape.organization_ids

        # admin can delete any site record
        # org member can only delete site that belongs to landscape
        #   that is associated to the org they are member of
        if not (current_user.is_admin || current_user.is_member_of_any(organization_ids))
            insufficient_privilege && return
        end
        @site = Site.find(params[:id])
        @site.destroy
    end

    private

    def site_params
        params.except(:format, :site).permit(:id, :site_name, :landscape_id, section_data_visibility: {})
    end
end
