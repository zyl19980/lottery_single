package task

import (
	"time"
)

// 上海时区，全局变量
var SysTimeLocation = func() *time.Location {
	loc, err := time.LoadLocation("Asia/Shanghai")
	if err != nil {
		loc = time.FixedZone("CST", 8*3600) // 如果加载失败，使用固定时区 UTC+8
	}
	return loc
}()
