class AmicaClient < FoodClient
  
  def initialize(restaurant, date = Date.today)
    restaurants = {
      quartetto_plus: 3114,
      gongi: 3110
    }
    @restaurant_id = restaurants[restaurant.to_sym]
    @date = date
  end

  def load_menus
    response = RestClient.get(url(@restaurant_id, @date))
    data = JSON.parse(response.body)
    @restaurant_name = data['RestaurantName']
    @restaurant_url = data['RestaurantUrl']

    current_menus = data['MenusForDays'].first
    @menus = []
    if current_menus['Date'] == "#{@date}T00:00:00"
      current_menus['SetMenus'].each do |menu|
        name = menu['Name']
        next if name != nil && ['FRESH BUFFET', 'STREET GOURMET', 'JUST FOR YOU', 'KEITTOLOUNAS'].include?(name.upcase)
        @menus.push( menu['Components'].map { |name| clean_name(name) }.join(', '))
      end
    end
  end
  
  def url(restaurant_id, date)
    "http://www.amica.fi/modules/json/json/Index?costNumber=#{restaurant_id}&firstDay=#{date}&lastDay=#{date}&language=fi"
  end 
  
  def clean_name(name)
    name.gsub(/(\(.*\))/, '').strip
  end
  
end
