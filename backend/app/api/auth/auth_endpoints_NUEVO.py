from fastapi import APIRouter, HTTPException
from pydantic import BaseModel
import requests

router = APIRouter()

class AuthRequest(BaseModel):
    username: str
    password: str

@router.post("/api/auth/login")
def login(auth_request: AuthRequest):
    url = 'http://tu-backend.com/api/auth/login'
    payload = {
        'username': auth_request.username,
        'password': auth_request.password
    }
    headers = {
        'Content-Type': 'application/json; charset=UTF-8'
    }
    response = requests.post(url, json=payload, headers=headers)
    
    if response.status_code == 200:
        response_body = response.json()
        token = response_body.get('token')
        if token:
            return {"token": token}
        else:
            raise HTTPException(status_code=500, detail="Token not found in response")
    else:
        raise HTTPException(status_code=response.status_code, detail="Authentication failed")