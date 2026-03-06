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
  ["living/image13.jpeg", { "natural_artificial" => 64, "luxury_casual" => 82, "soft_solid" => 55, "classic_modern" => 28, "simple_detail"=> 68, "chic_pop"=> 30}]
# ここにデータを50個分入れる。後から追加した場合は続けるだけでOK。もともとあったものは更新され、ないものは新しく作られる。
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