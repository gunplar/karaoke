import sys
import asyncio
import websockets
import json

async def main():
    if len(sys.argv) < 2:
        print("Usage: python3 ws_tunesplit.py <audio_file>")
        sys.exit(1)
    audio_file = sys.argv[1]
    uri = "ws://localhost:3003/separate"
    async with websockets.connect(
        uri,
        max_size=None,
        max_queue=None
    ) as ws:
        await ws.send(json.dumps({"type":"stems","data":"TWO_STEMS"}))
        with open(audio_file, "rb") as f:
            await ws.send(f.read())
        while True:
            msg = await ws.recv()
            if isinstance(msg, bytes):
                with open(f'{audio_file}.zip', "wb") as out:
                    out.write(msg)
                print(f'\nReceived {audio_file}.zip')
                break
            else:
                print('\rProgress: ' + msg, end='', flush=True)

asyncio.run(main())
