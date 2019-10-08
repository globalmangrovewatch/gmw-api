namespace :worldwide do
  desc "Create worlwide location"

  task :location => [:environment] do
    worlwide = Location.find_by(location_id: 'worldwide')

    worlwide_result = Location.select([
      'sum(area_m2) as area_m2',
      'sum(perimeter_m) as perimeter_m',
      'sum(coast_length_m) as coast_length_m',
    ])

    unless worlwide
      Location.create(
        name: 'Worldwide',
        location_type: 'worldwide',
        iso: 'WORDLWIDE',
        area_m2: worlwide_result[0][:area_m2],
        perimeter_m: worlwide_result[0][:perimeter_m],
        coast_length_m: worlwide_result[0][:coast_length_m],
        location_id: 'worldwide'
      )

      puts 'Location Worldwide created'
    else
      worlwide.update(
        area_m2: worlwide_result[0][:area_m2],
        perimeter_m: worlwide_result[0][:perimeter_m],
        coast_length_m: worlwide_result[0][:coast_length_m],
      )

      puts 'Location Worldwide updated'
    end
  end

  task :mangrove_datum => [:environment] do
    worldwide = Location.find_by(location_id: 'worldwide')

    mangrove_datum_result = MangroveDatum.select([
      'date',
      'sum(gain_m2) as gain_m2',
      'sum(loss_m2) as loss_m2',
      'sum(length_m) as length_m',
      'sum(area_m2) as area_m2',
      'avg(hmax_m) as hmax_m',
      'avg(agb_mgha_1) as agb_mgha_1',
      'avg(hba_m) as hba_m',
    ]).group('date')

    mangrove_datum_result.each do |m|
      mangrove_datum_item = MangroveDatum.find_by(date: m[:date], location_id: worldwide.id)

      unless mangrove_datum_item
        MangroveDatum.create!(
          date: m[:date],
          gain_m2: m[:gain_m2],
          loss_m2: m[:loss_m2],
          length_m: m[:length_m],
          area_m2: m[:area_m2],
          hmax_m: m[:hmax_m],
          agb_mgha_1: m[:agb_mgha_1],
          hba_m: m[:hba_m],
          location_id: worldwide.id,
        )

        puts 'MangroveDatum Worldwide created'
      else
        mangrove_datum_item.update(
          date: m[:date],
          gain_m2: m[:gain_m2],
          loss_m2: m[:loss_m2],
          length_m: m[:length_m],
          area_m2: m[:area_m2],
          hmax_m: m[:hmax_m],
          agb_mgha_1: m[:agb_mgha_1],
          hba_m: m[:hba_m],
        )

        puts 'MangroveDatum Worldwide updated'
      end
    end
  end
end
