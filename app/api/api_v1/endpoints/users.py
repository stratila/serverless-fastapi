from fastapi import APIRouter

router = APIRouter()


@router.get("/")
async def get_users():
    return {"message": "Users!"}


@router.get("/users/me")
async def get_user_me():
    return {"message": "User me!"}
