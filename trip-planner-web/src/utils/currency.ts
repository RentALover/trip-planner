export function formatCurrency(amount: number | null | undefined): string {
  if (amount == null) return '¥0.00'
  return '¥' + Number(amount).toFixed(2)
}

export function getTransportLabel(type: string): string {
  const map: Record<string, string> = {
    WALK: '步行', BUS: '公交', SUBWAY: '地铁',
    TAXI: '出租车', RIDE_HAIL: '网约车', SELF_DRIVE: '自驾', BIKE: '共享单车'
  }
  return map[type] || type
}

export function getItemTypeLabel(type: string): string {
  const map: Record<string, string> = {
    TRANSPORT: '交通', ACCOMMODATION: '住宿', DINING: '餐饮',
    ATTRACTION: '景点/游玩', SHOPPING: '购物', OTHER: '其他'
  }
  return map[type] || type
}

export function getTransportColor(type: string): string {
  const map: Record<string, string> = {
    WALK: '#66BB6A', BUS: '#42A5F5', SUBWAY: '#26C6DA',
    TAXI: '#FFA726', RIDE_HAIL: '#AB47BC', SELF_DRIVE: '#78909C', BIKE: '#9CCC65'
  }
  return map[type] || '#909399'
}

export function getStatusLabel(status: string): string {
  const map: Record<string, string> = {
    PLANNING: '规划中', COMPLETED: '已完成', CANCELLED: '已取消'
  }
  return map[status] || status
}
