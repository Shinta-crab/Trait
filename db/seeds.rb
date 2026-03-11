# db/seeds.rb

# 1. ジャンルの作成
# 変数名を genres_data に統一
genres_data = [
  { name: "リビング", icon: "🛋️", slug: "living" },
  { name: "ダイニング", icon: "🍽️", slug: "dining" },
  { name: "キッチン", icon: "🍳", slug: "kitchen" },
  { name: "水回り", icon: "🚿", slug: "sanitary" },
  { name: "寝室", icon: "🛌", slug: "bedroom" },
  { name: "玄関", icon: "🚪", slug: "entrance" }
]

genres_data.each do |data|
  # find_or_initialize_by + update! にすることで、
  # 既存データの名前やアイコンが修正された場合も反映されます
  Genre.find_or_initialize_by(slug: data[:slug]).update!(
    name: data[:name],
    icon: data[:icon]
  )
end

# 2. 6つの分析軸の作成
axis_data = [
  { name: "natural_artificial", min: "Artificial", max: "Natural" },
  { name: "luxury_casual",      min: "Casual",     max: "Luxury" },
  { name: "soft_solid",         min: "Solid",      max: "Soft" },
  { name: "classic_modern",   min: "Modern",     max: "Classic" },
  { name: "simple_detail",      min: "Simple",     max: "Detail" },
  { name: "chic_pop",           min: "Chic",       max: "Pop" }
]

axis_data.each do |data|
  Axis.find_or_initialize_by(name: data[:name]).update!(
    label_min: data[:min],
    label_max: data[:max]
  )
end

# 3. 写真とスコアの登録（ここは今のままでも概ねOKですが、再取得を確実に）
living = Genre.find_by!(slug: "living") # 見つからないと困るので ! をつけるのがコツ
axes_map = Axis.all.index_by(&:name)

photo_list = [
  ["living/image0.jpeg", { "natural_artificial" => 78, "luxury_casual" => 72, "soft_solid" => 58, "classic_modern" => 64, "simple_detail"=> 67, "chic_pop"=> 22}], 
  ["living/image1.jpeg", { "natural_artificial" => 90, "luxury_casual" => 68, "soft_solid" => 86, "classic_modern" => 48, "simple_detail"=> 62, "chic_pop"=> 28}],
  ["living/image2.jpeg", { "natural_artificial" => 92, "luxury_casual" => 70, "soft_solid" => 88, "classic_modern" => 42, "simple_detail"=> 28, "chic_pop"=> 12}], 
  ["living/image3.jpeg", { "natural_artificial" => 65, "luxury_casual" => 88, "soft_solid" => 72, "classic_modern" => 18, "simple_detail"=> 55, "chic_pop"=> 10}],
  ["living/image4.jpeg", { "natural_artificial" => 88, "luxury_casual" => 82, "soft_solid" => 84, "classic_modern" => 30, "simple_detail"=> 38, "chic_pop"=> 8}],  
  ["living/image5.jpeg", { "natural_artificial" => 85, "luxury_casual" => 55, "soft_solid" => 78, "classic_modern" => 35, "simple_detail"=> 72, "chic_pop"=> 40}],
  ["living/image6.jpeg", { "natural_artificial" => 40, "luxury_casual" => 92, "soft_solid" => 70, "classic_modern" => 10, "simple_detail"=> 45, "chic_pop"=> 5}],
  ["living/image7.jpeg", { "natural_artificial" => 75, "luxury_casual" => 80, "soft_solid" => 65, "classic_modern" => 70, "simple_detail"=> 68, "chic_pop"=> 35}],
  ["living/image8.jpeg", { "natural_artificial" => 82, "luxury_casual" => 60, "soft_solid" => 90, "classic_modern" => 55, "simple_detail"=> 85, "chic_pop"=> 65}],
  ["living/image9.jpeg", { "natural_artificial" => 78, "luxury_casual" => 88, "soft_solid" => 35, "classic_modern" => 15, "simple_detail"=> 20, "chic_pop"=> 5}],
  ["living/image10.jpeg", { "natural_artificial" => 72, "luxury_casual" => 45, "soft_solid" => 78, "classic_modern" => 48, "simple_detail"=> 82, "chic_pop"=> 68}],
  ["living/image11.jpeg", { "natural_artificial" => 88, "luxury_casual" => 82, "soft_solid" => 55, "classic_modern" => 35, "simple_detail"=> 60, "chic_pop"=> 20}],
  ["living/image12.jpeg", { "natural_artificial" => 78, "luxury_casual" => 90, "soft_solid" => 42, "classic_modern" => 22, "simple_detail"=> 72, "chic_pop"=> 12}],         
  ["living/image13.jpeg", { "natural_artificial" => 64, "luxury_casual" => 82, "soft_solid" => 55, "classic_modern" => 28, "simple_detail"=> 68, "chic_pop"=> 30}],
  ["living/image14.jpeg", { "natural_artificial" => 82, "luxury_casual" => 88, "soft_solid" => 86, "classic_modern" => 38, "simple_detail"=> 70, "chic_pop"=> 65}],
  ["living/image15.jpeg", { "natural_artificial" => 85, "luxury_casual" => 75, "soft_solid" => 72, "classic_modern" => 20, "simple_detail"=> 40, "chic_pop"=> 18}],
  ["living/image16.jpeg", { "natural_artificial" => 65, "luxury_casual" => 82, "soft_solid" => 42, "classic_modern" => 12, "simple_detail"=> 38, "chic_pop"=> 10}],
  ["living/image17.jpeg", { "natural_artificial" => 35, "luxury_casual" => 68, "soft_solid" => 38, "classic_modern" => 8, "simple_detail"=> 22, "chic_pop"=> 12}],
  ["living/image18.jpeg", { "natural_artificial" => 72, "luxury_casual" => 78, "soft_solid" => 64, "classic_modern" => 10, "simple_detail"=> 14, "chic_pop"=> 6}],
  ["living/image19.jpeg", { "natural_artificial" => 88, "luxury_casual" => 42, "soft_solid" => 76, "classic_modern" => 46, "simple_detail"=> 58, "chic_pop"=> 48}],
  ["living/image20.jpeg", { "natural_artificial" => 70, "luxury_casual" => 55, "soft_solid" => 45, "classic_modern" => 50, "simple_detail"=> 75, "chic_pop"=> 30}],
  ["living/image21.jpeg", { "natural_artificial" => 60, "luxury_casual" => 55, "soft_solid" => 70, "classic_modern" => 10, "simple_detail"=> 5, "chic_pop"=> 0}],
  ["living/image22.jpeg", { "natural_artificial" => 88, "luxury_casual" => 70, "soft_solid" => 92, "classic_modern" => 85, "simple_detail"=> 75, "chic_pop"=> 15}],
  ["living/image23.jpeg", { "natural_artificial" => 85, "luxury_casual" => 65, "soft_solid" => 75, "classic_modern" => 35, "simple_detail"=> 70, "chic_pop"=> 45}],
  ["living/image24.jpeg", { "natural_artificial" => 70, "luxury_casual" => 90, "soft_solid" => 60, "classic_modern" => 25, "simple_detail"=> 40, "chic_pop"=> 75}],
  ["living/image25.jpeg", { "natural_artificial" => 80, "luxury_casual" => 55, "soft_solid" => 65, "classic_modern" => 40, "simple_detail"=> 85, "chic_pop"=> 60}],
  ["living/image26.jpeg", { "natural_artificial" => 74, "luxury_casual" => 28, "soft_solid" => 68, "classic_modern" => 34, "simple_detail"=> 72, "chic_pop"=> 88}],
  ["living/image27.jpeg", { "natural_artificial" => 62, "luxury_casual" => 34, "soft_solid" => 57, "classic_modern" => 24, "simple_detail"=> 66, "chic_pop"=> 36}],
  ["living/image28.jpeg", { "natural_artificial" => 66, "luxury_casual" => 38, "soft_solid" => 64, "classic_modern" => 46, "simple_detail"=> 82, "chic_pop"=> 52}],
  ["living/image29.jpeg", { "natural_artificial" => 58, "luxury_casual" => 52, "soft_solid" => 71, "classic_modern" => 32, "simple_detail"=> 18, "chic_pop"=> 14}],
  ["living/image30.jpeg", { "natural_artificial" => 88, "luxury_casual" => 72, "soft_solid" => 83, "classic_modern" => 90, "simple_detail"=> 76, "chic_pop"=> 12}],
  ["living/image31.jpeg", { "natural_artificial" => 86, "luxury_casual" => 60, "soft_solid" => 88, "classic_modern" => 66, "simple_detail"=> 78, "chic_pop"=> 24}],
  ["living/image32.jpeg", { "natural_artificial" => 61, "luxury_casual" => 64, "soft_solid" => 72, "classic_modern" => 38, "simple_detail"=> 36, "chic_pop"=> 41}],
  ["living/image33.jpeg", { "natural_artificial" => 92, "luxury_casual" => 63, "soft_solid" => 41, "classic_modern" => 86, "simple_detail"=> 58, "chic_pop"=> 18}],
  ["living/image34.jpeg", { "natural_artificial" => 90, "luxury_casual" => 68, "soft_solid" => 63, "classic_modern" => 64, "simple_detail"=> 42, "chic_pop"=> 22}],
  ["living/image35.jpeg", { "natural_artificial" => 94, "luxury_casual" => 42, "soft_solid" => 78, "classic_modern" => 72, "simple_detail"=> 64, "chic_pop"=> 58}],
  ["living/image36.jpeg", { "natural_artificial" => 54, "luxury_casual" => 66, "soft_solid" => 59, "classic_modern" => 42, "simple_detail"=> 24, "chic_pop"=> 18}],
  ["living/image37.jpeg", { "natural_artificial" => 85, "luxury_casual" => 52, "soft_solid" => 72, "classic_modern" => 68, "simple_detail"=> 44, "chic_pop"=> 10}],
  ["living/image38.jpeg", { "natural_artificial" => 78, "luxury_casual" => 57, "soft_solid" => 62, "classic_modern" => 32, "simple_detail"=> 46, "chic_pop"=> 38}],
  ["living/image39.jpeg", { "natural_artificial" => 58, "luxury_casual" => 63, "soft_solid" => 48, "classic_modern" => 42, "simple_detail"=> 72, "chic_pop"=> 28}],
  ["living/image40.jpeg", { "natural_artificial" => 65, "luxury_casual" => 85, "soft_solid" => 70, "classic_modern" => 20, "simple_detail"=> 40, "chic_pop"=> 35}],
  ["living/image41.jpeg", { "natural_artificial" => 62, "luxury_casual" => 74, "soft_solid" => 91, "classic_modern" => 18, "simple_detail"=> 28, "chic_pop"=> 6}],
  ["living/image42.jpeg", { "natural_artificial" => 90, "luxury_casual" => 38, "soft_solid" => 74, "classic_modern" => 36, "simple_detail"=> 82, "chic_pop"=> 64}],
  ["living/image43.jpeg", { "natural_artificial" => 87, "luxury_casual" => 34, "soft_solid" => 68, "classic_modern" => 46, "simple_detail"=> 88, "chic_pop"=> 72}],
  ["living/image44.jpeg", { "natural_artificial" => 64, "luxury_casual" => 79, "soft_solid" => 54, "classic_modern" => 41, "simple_detail"=> 72, "chic_pop"=> 14}],
  ["living/image45.jpeg", { "natural_artificial" => 88, "luxury_casual" => 64, "soft_solid" => 90, "classic_modern" => 58, "simple_detail"=> 42, "chic_pop"=> 8}],
  ["living/image46.jpeg", { "natural_artificial" => 58, "luxury_casual" => 46, "soft_solid" => 84, "classic_modern" => 44, "simple_detail"=> 90, "chic_pop"=> 78}],
  ["living/image47.jpeg", { "natural_artificial" => 68, "luxury_casual" => 66, "soft_solid" => 76, "classic_modern" => 18, "simple_detail"=> 24, "chic_pop"=> 10}],
  ["living/image48.jpeg", { "natural_artificial" => 84, "luxury_casual" => 42, "soft_solid" => 82, "classic_modern" => 48, "simple_detail"=> 72, "chic_pop"=> 58}],
  ["living/image49.jpeg", { "natural_artificial" => 56, "luxury_casual" => 38, "soft_solid" => 64, "classic_modern" => 14, "simple_detail"=> 62, "chic_pop"=> 86}]
]

photo_list.each do |path, scores|
  photo = Photo.find_or_create_by!(
    image_path: path,
    genre: living
  )

  scores.each do |axis_name, value|
    axis = axes_map[axis_name]
    next unless axis

    PhotoScore.find_or_initialize_by(photo: photo, axis: axis).update!(score: value)
  end
end