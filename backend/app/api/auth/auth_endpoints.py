import requests  # Importa el módulo requests para hacer solicitudes HTTP

# Constantes que contienen la URL del servicio, el nombre de usuario y la contraseña
URL = 'http://172.20.1.55/soportegiades/apirest.php'
USERNAME = 'rtascon'
PASSWORD = '-Capacho600'

def iniciar_sesion(url, username, password):
    """Inicia sesion en GLPI y devuelve el token de sesion."""
    # Construye la URL completa para la solicitud de inicio de sesión
    login_url = f"{url}/initSession"
    
    # Crea un diccionario con las credenciales de inicio de sesión
    payload = {
        'login': username,
        'password': password
    }

    # Realiza una solicitud HTTP POST a la URL de inicio de sesión, enviando el payload como JSON
    response = requests.post(login_url, json=payload)

    # Si la respuesta tiene un código de estado 200 (OK), convierte la respuesta a JSON y devuelve el token de sesión
    if response.status_code == 200:
        respuesta = response.json()
        return response.json()['session_token']
    else:
        # Si la respuesta no tiene un código de estado 200, lanza una excepción con un mensaje de error
        raise Exception("Error al iniciar sesion: " + response.text)

def obtener_getFullSession(url, session_token):
    """Obtiene la informacion completa de la sesion del usuario."""
    # Construye la URL completa para la solicitud de obtener la sesión completa
    user_url = f"{url}/getFullSession"
    
    # Configura los encabezados de la solicitud, incluyendo el token de sesión y el tipo de contenido
    headers = {
        'Session-Token': session_token,
        "Content-Type": "application/json"
    }
    
    # Realiza una solicitud HTTP GET a la URL de obtener la sesión completa
    response = requests.get(user_url, headers=headers)
    
    # Si la respuesta tiene un código de estado 200 (OK) o 206 (Partial Content), convierte la respuesta a JSON y devuelve la información de la sesión
    if response.status_code == 200 or response.status_code == 206: 
        return response.json()
    else:
        # Si la respuesta no tiene un código de estado 200 o 206, lanza una excepción con un mensaje de error
        raise Exception("Error al obtener informacion del usuario: " + response.text)

#TODAVIA FALTA PROBAR ESTA FUNCION
def obtener_permisos(url, session_token, id_perfil):
    """Obtiene los permisos del perfil especificado."""
    # Construye la URL completa para la solicitud de obtener los permisos del perfil
    user_url = f"{url}/Profile/" + str(id_perfil) + "/getActiveProfile"
    
    # Configura los encabezados de la solicitud, incluyendo el token de sesión y el tipo de contenido
    headers = {
        'Session-Token': session_token,
        "Content-Type": "application/json"
    }
    
    # Realiza una solicitud HTTP GET a la URL de obtener los permisos del perfil
    response = requests.get(user_url, headers=headers)
    
    # Si la respuesta tiene un código de estado 200 (OK) o 206 (Partial Content), convierte la respuesta a JSON y devuelve la información de los permisos
    if response.status_code == 200 or response.status_code == 206: 
        return response.json()
    else:
        # Si la respuesta no tiene un código de estado 200 o 206, lanza una excepción con un mensaje de error
        raise Exception("Error al obtener informacion del usuario: " + response.text)

def obtener_getMyProfiles(url, session_token):
    """Obtiene los perfiles del usuario conectado."""
    # Construye la URL completa para la solicitud de obtener los perfiles del usuario
    user_url = f"{url}/getMyProfiles"
    
    # Configura los encabezados de la solicitud, incluyendo el token de sesión y el tipo de contenido
    headers = {
        'Session-Token': session_token,
        "Content-Type": "application/json"
    }
    
    # Realiza una solicitud HTTP GET a la URL de obtener los perfiles del usuario
    response = requests.get(user_url, headers=headers)
    
    # Si la respuesta tiene un código de estado 200 (OK) o 206 (Partial Content), convierte la respuesta a JSON y devuelve la información de los perfiles
    if response.status_code == 200 or response.status_code == 206: 
        return response.json()
    else:
        # Si la respuesta no tiene un código de estado 200 o 206, lanza una excepción con un mensaje de error
        raise Exception("Error al obtener informacion del usuario: " + response.text)

def listar_usuarios(url, session_token):
    """Lista todos los usuarios del sistema."""
    # Construye la URL completa para la solicitud de listar los usuarios
    user_url = f"{url}/User"
    
    # Configura los encabezados de la solicitud, incluyendo el token de sesión y el tipo de contenido
    headers = {
        'Session-Token': session_token,
        "Content-Type": "application/json"
    }
    
    # Realiza una solicitud HTTP GET a la URL de listar los usuarios
    response = requests.get(user_url, headers=headers)
    
    # Si la respuesta tiene un código de estado 200 (OK) o 206 (Partial Content), convierte la respuesta a JSON y devuelve la lista de usuarios
    if response.status_code == 200 or response.status_code == 206: 
        return response.json()
    else:
        # Si la respuesta no tiene un código de estado 200 o 206, lanza una excepción con un mensaje de error
        raise Exception("Error al obtener informacion del usuario: " + response.text)

def obtener_usuario_info(url, session_token):
    """Obtiene la informacion del usuario conectado."""
    # Construye la URL completa para la solicitud de obtener la información del usuario actual
    user_url = f"{url}/getCurrentUser"
    
    # Configura los encabezados de la solicitud, incluyendo el token de sesión y el tipo de contenido
    headers = {
        'Session-Token': session_token,
        "Content-Type": "application/json"
    }
    
    # Realiza una solicitud HTTP GET a la URL de obtener la información del usuario actual
    response = requests.get(user_url, headers=headers)
    
    # Si la respuesta tiene un código de estado 200 (OK), convierte la respuesta a JSON y devuelve la información del usuario
    if response.status_code == 200:
        return response.json()
    else:
        # Si la respuesta no tiene un código de estado 200, lanza una excepción con un mensaje de error
        raise Exception("Error al obtener informacion del usuario: " + response.text)

def cerrar_sesion(url, session_token):
    """Cierra la sesion del usuario."""
    # Construye la URL completa para la solicitud de cerrar la sesión
    logout_url = f"{url}/killSession"
    
    # Configura los encabezados de la solicitud, incluyendo el token de sesión
    headers = {
        'Session-Token': session_token
    }
    
    # Realiza una solicitud HTTP POST a la URL de cerrar la sesión
    response = requests.post(logout_url, headers=headers)
    
    # Si la respuesta tiene un código de estado 200 (OK), la sesión se ha cerrado correctamente
    if response.status_code != 200:
        # Si la respuesta no tiene un código de estado 200, lanza una excepción con un mensaje de error
        raise Exception("Error al cerrar sesion: " + response.text)

# Ejecución del flujo principal
try:
    # Inicia sesión y obtiene el token de sesión
    session_token = iniciar_sesion(URL, USERNAME, PASSWORD)
    print("Sesion iniciada. Token de sesion:", session_token)

    # Obtiene los perfiles del usuario y los permisos del perfil especificado
    user_info = obtener_getMyProfiles(URL, session_token)
    permisos_info = obtener_permisos(URL, session_token, user_info["myprofiles"][0]["id"])
    #user_info = obtener_getFullSession(URL, session_token)
    #user_info = listar_usuarios(URL, session_token)
    #user_info = obtener_usuario_info(URL, session_token)
    print("Informacion del usuario:", user_info)

finally:
    # Cierra la sesión
    cerrar_sesion(URL, session_token)
    print("Sesion cerrada.")