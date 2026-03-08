import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["nameInput"]
  
  // 💡 HTML側の data-style-selection-all-photo-ids-value は JS側で allPhotoIdsValue になります
  static values = {
    photoIds: String,
    allPhotoIds: String,
    genreId: Number,
    cx: Number,
    cy: Number,
    xAxis: String,
    yAxis: String
  }

  async save(event) {
    event.preventDefault()
    
    // デバッグ用：クリックされたことを確認
    console.log("Save button clicked!")
    
    const styleName = this.nameInputTarget.value
    
    // 送信データの確認（コンソールで値が入っているか見てください）
    const payload = { 
      custom_name: styleName,
      photo_ids: this.photoIdsValue,
      all_photo_ids: this.allPhotoIdsValue, 
      genre_id: this.genreIdValue,
      cx: this.cxValue,                     
      cy: this.cyValue,                     
      x_axis: this.xAxisValue,              
      y_axis: this.yAxisValue               
    }
    console.log("Payload:", payload)

    try {
      const response = await fetch('/my_styles', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'X-CSRF-Token': this.getCsrfToken()
        },
        body: JSON.stringify(payload)
      })

      const data = await response.json()

      if (response.status === 401) {
        alert("保存にはログインが必要です。")
        window.location.href = '/users/sign_up'
      } else if (response.ok) {
        console.log("Save success, redirecting...")
        window.location.href = '/dashboard'
      } else {
        throw new Error(data.message || "保存中にエラーが発生しました")
      }
    } catch (error) {
      console.error("Save Error:", error)
      alert("エラーが発生しました: " + error.message)
    }
  }

  getCsrfToken() {
    const tokenTag = document.querySelector('meta[name="csrf-token"]')
    return tokenTag ? tokenTag.content : ""
  }
}