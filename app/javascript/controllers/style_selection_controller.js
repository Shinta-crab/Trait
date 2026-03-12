import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["nameInput"]
  static values = {
    photoIds: String,    
    allPhotoIds: String, 
    genreId: Number,
    cx: Number,
    cy: Number,
    xAxis: String,
    yAxis: String
  }

  // 保存ボタンがクリックされた時の処理
  save(event) {
    event.preventDefault()

    const styleName = this.nameInputTarget.value

    fetch('/my_styles', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json', // JSONレスポンスを明確に要求
        'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').content
      },
      body: JSON.stringify({ 
        custom_name: styleName,
        photo_ids: this.photoIdsValue,
        all_photo_ids: this.allPhotoIdsValue,
        genre_id: this.genreIdValue,
        cx: this.cxValue,
        cy: this.cyValue,
        x_axis: this.xAxisValue,
        y_axis: this.yAxisValue
      })
    })
    .then(async response => {
      // 401 Unauthorized を検知
      if (response.status === 401) {
        alert("スタイルの保存には新規アカウント登録、ログインが必要です。")
        window.location.href = '/'
        return null
      }
      
      // それ以外は通常通りJSONとして解析
      return response.json()
    })
    .then(data => {
      if (!data) return // 401で中断された場合は何もしない

      if (data.status === 'success') {
        window.location.href = data.redirect_url || '/dashboard'
      } else {
        alert("エラーが発生しました: " + (data.message || "不明なエラー"))
      }
    })
    .catch(error => {
      console.error("Error:", error)
      alert("通信に失敗しました。再度お試しください。")
    })
  }
}