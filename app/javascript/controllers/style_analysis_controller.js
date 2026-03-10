import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "mainView", "mapView", "nameDisplay", "nameInput", "editInterface", 
    "plottedCards", "svg", "xSelect", "ySelect",
    "labelXMin", "labelXMax", "labelYMin", "labelYMax" // 追加しました
  ]
  static values = { 
    styleId: Number,
    allPhotos: Array,
    initialCx: Number,
    initialCy: Number
  }

  connect() {
    this.labelMap = {
      'luxury_casual': ['高級感', '親しみやすい'],
      'natural_artificial': ['ナチュラル', '人工的'],
      'simple_detail': ['シンプル', 'ディテール'],
      'soft_solid': ['柔らかい', 'クール'],
      'tradition_modern': ['伝統的', '先進的'],
      'chic_pop': ['シック', 'ポップ']
    }
    // connectではマップ表示に必要な処理は行わず、手動でshowMap経由で行う
  }

  // マップを表示し、アニメーションを開始
  showMap() {
    this.mainViewTarget.classList.add("hidden")
    this.mapViewTarget.classList.remove("hidden")
    // ここで初めてターゲットが存在する状態で計算する
    this.updatePositions()
  }

  // グリッド表示に戻す
  hideMap() {
    this.mapViewTarget.classList.add("hidden")
    this.mainViewTarget.classList.remove("hidden")
  }

  toggleEdit() {
    this.nameDisplayTarget.classList.toggle("hidden")
    this.editInterfaceTarget.classList.toggle("hidden")
  }

  async updateName() {
    const newName = this.nameInputTarget.value
    try {
      const response = await fetch(`/my_styles/${this.styleIdValue}`, {
        method: 'PATCH',
        headers: {
          'Content-Type': 'application/json',
          'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').content
        },
        body: JSON.stringify({ my_style: { custom_name: newName } })
      })
      if (response.ok) {
        this.nameDisplayTarget.querySelector('h1').innerText = newName
        this.toggleEdit()
      }
    } catch (error) {
      alert("名前の更新に失敗しました")
    }
  }

  updatePositions() {
    const xKey = this.xSelectTarget.value
    const yKey = this.ySelectTarget.value
    this.updateLabels(xKey, yKey)
    this.plottedCardsTarget.innerHTML = ""

    this.allPhotosValue.forEach((img, index) => {
      const item = document.createElement("div")
      item.className = "absolute w-12 h-16 bg-cover bg-center border border-white shadow-sm transition-all duration-1000 ease-in-out"
      item.style.backgroundImage = `url(${img.url})`
      
      const xPos = img.scores[xKey] || 50
      const yPos = img.scores[yKey] || 50
      
      item.style.left = "50%"
      item.style.top = "50%"
      item.style.opacity = "0"
      this.plottedCardsTarget.appendChild(item)

      setTimeout(() => {
        item.style.left = `${xPos}%`
        item.style.top = `${100 - yPos}%`
        item.style.opacity = "1"
        item.style.transform = `translate(-50%, -50%)`
      }, 50 + (index * 30))
    })

    this.drawStaticCircle(this.initialCxValue, this.initialCyValue)
  }
  
  updateLabels(xKey, yKey) {
    // ターゲットが存在するかチェックを入れることでエラーを回避
    if (this.hasLabelXMinTarget) this.labelXMinTarget.innerText = this.labelMap[xKey][0]
    if (this.hasLabelXMaxTarget) this.labelXMaxTarget.innerText = this.labelMap[xKey][1]
    if (this.hasLabelYMaxTarget) this.labelYMaxTarget.innerText = this.labelMap[yKey][1]
    if (this.hasLabelYMinTarget) this.labelYMinTarget.innerText = this.labelMap[yKey][0]
  }

  drawStaticCircle(cx, cy) {
    if (!this.hasSvgTarget) return
    this.svgTarget.innerHTML = ""
    const circle = document.createElementNS("http://www.w3.org/2000/svg", "circle")
    circle.setAttribute("cx", `${cx}%`)
    circle.setAttribute("cy", `${cy}%`)
    circle.setAttribute("r", "15%")
    circle.setAttribute("fill", "rgba(212, 163, 115, 0.15)")
    circle.setAttribute("stroke", "#d4a373")
    circle.setAttribute("stroke-width", "2")
    circle.setAttribute("stroke-dasharray", "4,4")
    this.svgTarget.appendChild(circle)
  }
}