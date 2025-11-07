package params

import "lottery_single/internal/service"

// PrizeListRequest 处理请求和响应的实体
type PrizeListRequest struct {
}

type PrizeListResponse struct {
}

type LoginReq struct {
	UserName string `json:"user_name"`
	PassWord string `json:"pass_word"`
}

type LoginRsp struct {
	UserID int
	Token  string
}

type LotteryReq struct {
	UserID uint   `json:"user_id"`
	Token  string `json:"token"`
	IP     string `json:"ip"`
}

type PrizeAddRequest struct {
	PrizeInfo service.ViewPrize
}
