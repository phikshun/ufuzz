class GenericConfig < UFuzz::Config
  def options
    {
      platform:     'Generic',
      use_ssl:      false,
      use_session:  false,
      #skip_urls:    /firmwareupdate1|UpdateWeeklyCalendar/, 
    }
  end
end