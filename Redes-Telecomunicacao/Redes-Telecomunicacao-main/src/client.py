import socket
import threading
import sys

def receive_messages(client_socket):
    while True:
        try:
            message = client_socket.recv(1024).decode('utf-8')
            if not message:
                break
            print(message)
        except:
            print("An error occurred!")
            client_socket.close()
            break

def main():
    if len(sys.argv) != 3:
        print("Usage: python client.py <SERVER_IP> <PORT>")
        return

    SERVER_IP = sys.argv[1]
    PORT = int(sys.argv[2])

    try:
        client_socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        print(f"Attempting to connect to {SERVER_IP}:{PORT}")
        client_socket.connect((SERVER_IP, PORT))
        print("Connected to the chat server.")
    except Exception as e:
        print(f"Failed to connect to the server: {e}")
        return

    username = input("Enter your username: ")
    client_socket.send(username.encode('utf-8'))

    threading.Thread(target=receive_messages, args=(client_socket,)).start()

    while True:
        message = input()
        if message.lower() == 'exit':
            client_socket.send(f"{username} has left the chat.".encode('utf-8'))
            client_socket.close()
            break
        client_socket.send(message.encode('utf-8'))

if __name__ == "__main__":
    main()
