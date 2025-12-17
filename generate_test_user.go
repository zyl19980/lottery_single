package main

import (
	"fmt"
	"golang.org/x/crypto/bcrypt"
)

// 生成测试用户的 bcrypt 密码哈希
// 使用方式: go run generate_test_user.go
func main() {
	passwords := []string{"123456", "admin123"}
	usernames := []string{"testuser", "admin"}

	fmt.Println("-- 生成的测试用户数据")
	fmt.Println("-- 使用方式: 将下面的 SQL 插入到数据库中")
	fmt.Println()

	for i, username := range usernames {
		password := passwords[i]
		hash, err := bcrypt.GenerateFromPassword([]byte(password), bcrypt.DefaultCost)
		if err != nil {
			fmt.Printf("生成密码哈希失败: %v\n", err)
			continue
		}

		fmt.Printf("-- 用户: %s, 密码: %s\n", username, password)
		fmt.Printf("INSERT INTO `t_user` (`user_name`, `pass_word`, `signature`) VALUES ('%s', '%s', '');\n", username, string(hash))
		fmt.Println()
	}

	fmt.Println("-- 验证生成的密码")
	testPassword := "123456"
	testHash, _ := bcrypt.GenerateFromPassword([]byte(testPassword), bcrypt.DefaultCost)
	err := bcrypt.CompareHashAndPassword(testHash, []byte(testPassword))
	if err == nil {
		fmt.Println("-- 密码验证成功！")
	} else {
		fmt.Printf("-- 密码验证失败: %v\n", err)
	}
}
