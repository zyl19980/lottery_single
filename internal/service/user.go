package service

import (
	"context"
	"fmt"
	"golang.org/x/crypto/bcrypt"
	"lottery_single/internal/pkg/constant"
	"lottery_single/internal/pkg/middlewares/gormcli"
	"lottery_single/internal/pkg/middlewares/log"
	"lottery_single/internal/pkg/utils"
	"lottery_single/internal/repo"
)

// UserService 用户功能
type UserService interface {
	Login(ctx context.Context, userName, passWord string) (*LoginRsp, error)
}

type userService struct {
	userReop *repo.UserRepo
}

var userServiceImpl *userService

func NewUserService() {
	userServiceImpl = &userService{
		userReop: repo.NewUserRepo(),
	}
}

func GetUserService() UserService {
	return userServiceImpl
}

func (p *userService) Login(ctx context.Context, userName, passWord string) (*LoginRsp, error) {
	info, err := p.userReop.GetByName(gormcli.GetDB(), userName)
	if err != nil {
		return nil, err
	}
	log.InfoContextf(ctx, "info is: +%v\n", info)
	log.InfoContextf(ctx, "info.Password=%s,passWord=%s\n", info.Password, passWord)
	// 验证密码是否正确
	err = bcrypt.CompareHashAndPassword([]byte(info.Password), []byte(passWord))
	if err != nil {
		return nil, fmt.Errorf("password error: %v", err)
	}
	token, err := utils.GenerateJwtToken(constant.SecretKey, constant.Issuer, info.Id, userName)
	if err != nil {
		return nil, err
	}
	response := &LoginRsp{
		UserID: info.Id,
		Token:  token,
	}
	return response, nil
}
