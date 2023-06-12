from fastapi import APIRouter

router = APIRouter()


@router.get("/")
async def get_users():
    return {"message": "Users!"}


@router.get("/me")
async def get_user_me():
    return {"message": "User me!"}


@router.get("/me/items")
async def get_user_me_items():
    return {"message": "User me items!"}
