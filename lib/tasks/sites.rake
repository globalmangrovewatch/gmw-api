namespace :sites do
  desc "Sync sites.area from registration_intervention_answers question 1.3"
  task sync_areas: :environment do
    answers = RegistrationInterventionAnswer.where(question_id: Site::SITE_AREA_QUESTION_ID).includes(:site)
    synced = 0
    skipped = 0
    failed = 0

    answers.find_each do |answer|
      site = answer.site
      geometry = Site.area_geometry_from_geojson_answer(answer.answer_value)

      if geometry.nil?
        skipped += 1
        puts "Skipped site #{site.id} (#{site.site_name}): no geometry derived from answer"
        next
      end

      site.update!(area: geometry)
      synced += 1
    rescue StandardError => e
      failed += 1
      puts "Failed site #{site.id} (#{site.site_name}): #{e.message}"
    end

    puts "Done. Synced: #{synced}, skipped: #{skipped}, failed: #{failed}"
  end
end
