def hello_pubsub(event, context):
    import base64
    print(f"Event: {event}")
    if 'data' in event:
        name = base64.b64decode(event['data']).decode('utf-8')
        print(f"Hello, {name}!")
    else:
        print("Hello, World!")
