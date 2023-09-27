<html>
<head>
    <title>Travel List</title>
</head>

<body>
    <h1>My Travel Bucket List| A PoC By Jahidul Arafat:: Laravel 6 and mysql 8 Dockerized and K8s Cluster</h1>
    <h2>Places I'd Like to Visit | Fetched From Database</h2>
    <ul>
      @foreach ($togo as $newplace)
        <li>{{ $newplace->name }}</li>
      @endforeach
    </ul>

    <h2>Places I've Already Been To | Fetched From Database</h2>
    <ul>
          @foreach ($visited as $place)
                <li>{{ $place->name }}</li>
          @endforeach
    </ul>
</body>
</html>
