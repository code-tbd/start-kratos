package server

import (
	"errors"
	"fmt"
	"github.com/go-kratos/kratos/v2/log"
	"github.com/tx7do/kratos-transport/transport/websocket"
	"start-kratos/app/cv/service/internal/conf"
)

const (
	MessageTypeChat = iota + 1
	MessageTypeControl
)

type Message struct {
	Sender  string `json:"sender"`
	Message string `json:"message"`
}

func NewWebsocketServer(c *conf.Server) *websocket.Server {
	server := websocket.NewServer(
		websocket.WithAddress(c.Websocket.Addr),
		websocket.WithTimeout(c.Websocket.Timeout.AsDuration()),
		websocket.WithPath("/ws"),
		websocket.WithCodec("json"),
		websocket.WithConnectHandle(connectHandler),
	)

	server.RegisterMessageHandler(MessageTypeChat,
		func(sessionId websocket.SessionID, payload websocket.MessagePayload) error {
			switch t := payload.(type) {
			case *Message:
				return handleMessage(server, sessionId, t)
			default:
				return errors.New("invalid payload type")
			}
		},
		func() websocket.Any { return &Message{} },
	)

	return server
}

func handleMessage(srv *websocket.Server, sid websocket.SessionID, in *Message) error {
	fmt.Println(in)
	out := &Message{
		Sender:  "server",
		Message: "测试",
	}
	srv.Broadcast(MessageTypeChat, out)
	return nil
}

func connectHandler(sid websocket.SessionID, connect bool) {
	if connect {
		log.Infof("[websocket] 新的会话: %v\n", sid)
	} else {
		log.Infof("[websocket] 会话断开: %v\n", sid)
	}
}
