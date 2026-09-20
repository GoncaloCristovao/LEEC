import socket
import threading

# Define server host and port
HOST = '0.0.0.0'  # Bind to all available interfaces
PORT = 12346

clients = []
clients_info = {}
usernames = {}
lock = threading.Lock()

def broadcast(message, _client_socket):
    for client in clients:
        if client != _client_socket:
            try:
                client.send(message.encode('utf-8'))
            except:
                client.close()
                if client in clients:
                    clients.remove(client)

def handle_client(client_socket, client_address):
    with lock:
        clients_info[client_address] = 0

    username = client_socket.recv(1024).decode('utf-8')
    with lock:
        usernames[client_socket] = username

    welcome_message = f"{username} has joined the chat!"
    print(welcome_message)
    broadcast(welcome_message, client_socket)

    while True:
        try:
            message = client_socket.recv(1024).decode('utf-8')
            if not message:
                break
            with lock:
                clients_info[client_address] += 1
                print(f"Received {clients_info[client_address]} messages from {username} ({client_address})")
            broadcast(f"{username}: {message}", client_socket)
        except:
            break

    client_socket.close()
    with lock:
        clients.remove(client_socket)
        del clients_info[client_address]
        del usernames[client_socket]
    broadcast(f"{username} has left the chat.", client_socket)

def main():
    server_socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    server_socket.bind((HOST, PORT))
    server_socket.listen()

    print(f"Server listening on {HOST}:{PORT}")

    while True:
        client_socket, client_address = server_socket.accept()
        with lock:
            clients.append(client_socket)
        print(f"Connection from {client_address}")
        client_socket.send("Enter your username: ".encode('utf-8'))
        threading.Thread(target=handle_client, args=(client_socket, client_address)).start()

if __name__ == "__main__":
    main()
