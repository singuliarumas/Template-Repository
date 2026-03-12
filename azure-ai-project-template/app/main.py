"""Minimal FastAPI application template for Azure AI projects."""

import os
import logging

from fastapi import FastAPI, HTTPException
from pydantic import BaseModel

logger = logging.getLogger(__name__)

app = FastAPI(
    title="Azure AI Project",
    version="0.1.0",
    docs_url="/docs",
)


class HealthResponse(BaseModel):
    status: str
    version: str


class ChatRequest(BaseModel):
    message: str
    model: str = "gpt-4o"
    max_tokens: int = 1000


class ChatResponse(BaseModel):
    reply: str
    model: str
    usage: dict | None = None


@app.get("/health", response_model=HealthResponse)
async def health_check():
    """Health check endpoint for App Service and load balancers."""
    return HealthResponse(status="healthy", version="0.1.0")


@app.post("/chat", response_model=ChatResponse)
async def chat(request: ChatRequest):
    """Chat endpoint — replace with your AI logic.

    This is a placeholder. Integrate with Azure OpenAI SDK:
        from openai import AzureOpenAI
        client = AzureOpenAI(
            azure_endpoint=os.environ["AZURE_OPENAI_ENDPOINT"],
            azure_ad_token_provider=get_bearer_token_provider(...),
            api_version="2024-06-01",
        )
    """
    # Placeholder response
    return ChatResponse(
        reply=f"Echo: {request.message}",
        model=request.model,
        usage={"prompt_tokens": 0, "completion_tokens": 0},
    )


@app.get("/")
async def root():
    return {"message": "Azure AI Project Template", "docs": "/docs"}
