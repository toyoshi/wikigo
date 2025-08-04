document.addEventListener('DOMContentLoaded', function() {
  const aiEditBtn = document.getElementById('ai-edit-btn');
  
  if (aiEditBtn) {
    aiEditBtn.addEventListener('click', function() {
      const wordId = this.dataset.wordId;
      const trixEditor = document.querySelector('trix-editor');
      
      if (!trixEditor) {
        alert('エディターが見つかりません');
        return;
      }
      
      // ボタンを無効化してローディング状態にする
      const originalText = this.innerHTML;
      this.disabled = true;
      this.innerHTML = '🔄 生成中...';
      
      // Ajax リクエストを送信
      fetch(`/${wordId}/ai_edit`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').getAttribute('content')
        }
      })
      .then(response => response.json())
      .then(data => {
        if (data.success) {
          // Trixエディターにコンテンツを設定
          trixEditor.editor.setDocument(Trix.Document.fromString(data.content));
          
          // 成功メッセージを表示
          showMessage('AIによるコンテンツ生成が完了しました', 'success');
        } else {
          // エラーメッセージを表示
          showMessage(`エラー: ${data.error}`, 'error');
        }
      })
      .catch(error => {
        console.error('Error:', error);
        showMessage('ネットワークエラーが発生しました', 'error');
      })
      .finally(() => {
        // ボタンを元の状態に戻す
        this.disabled = false;
        this.innerHTML = originalText;
      });
    });
  }
  
  // メッセージ表示用のヘルパー関数
  function showMessage(message, type) {
    // 既存のメッセージがあれば削除
    const existingMessage = document.querySelector('.ai-edit-message');
    if (existingMessage) {
      existingMessage.remove();
    }
    
    // 新しいメッセージを作成
    const messageDiv = document.createElement('div');
    messageDiv.className = `alert alert-${type === 'success' ? 'success' : 'danger'} alert-dismissible fade show ai-edit-message`;
    messageDiv.innerHTML = `
      ${message}
      <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
    `;
    
    // フォームの上部に挿入
    const form = document.querySelector('form');
    if (form) {
      form.insertAdjacentElement('beforebegin', messageDiv);
      
      // 3秒後に自動的に削除
      setTimeout(() => {
        if (messageDiv && messageDiv.parentNode) {
          messageDiv.remove();
        }
      }, 3000);
    }
  }
});