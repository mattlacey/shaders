
struct ray
{
    vec3 origin;
    vec3 direction;
};

vec3 rayAt(ray r, float t)
{
    return r.origin + t*r.direction;
}

struct sphere
{
    vec3 centre;
    float radius;
    vec3 col;
};

sphere makeSphere(vec3 centre, float radius, vec3 col)
{
    sphere s;
    s.centre = centre;
    s.radius = radius;
    s.col = col;
    return s;
}

// calculates the value of t for the ray requation at which the ray
// hits the sphere
float testSphere(ray r, sphere s)
{
    vec3 oc = r.origin - s.centre;
    float a = dot(r.direction, r.direction);
    float b = 2.0 * dot(oc, r.direction);
    float c = dot(oc, oc) - s.radius*s.radius;

    float disc = b*b - 4.0*a*c;

    if (disc >= 0.0)
    {
        return (-b - sqrt(disc)) / (2.0*a);
    }

    return -1.0;
}

vec4 rayColour(ray r)
{
    float time = iGlobalTime * 1.0;
    vec3 light = normalize(vec3(1.0, 1.0, 1.0));

    light.x = sin(time);
    light.z = cos(time);

    const int sphereCount = 3;
    sphere spheres[sphereCount];
    spheres[0] = makeSphere(vec3(-.5, 0.0, 1.0), 0.5, vec3(1.0, 0.0, 0.0));
    spheres[1] = makeSphere(vec3(0.0, -100.5, 1.0), 100.0, vec3(0.0, 1.0, 0.0));
    spheres[2] = makeSphere(vec3(0.0, 0.2, 1.5), 0.25, vec3(0.0, 0.0, 1.0));

    float closestT = 1000000.0;
    int closestSphere = -1;

    for(int i = 0; i < sphereCount; i++)
    {
        float t = testSphere(r, spheres[i]);

        if (t > 0.0)
        {
            if (t < closestT)
            {
                closestT = t;
                closestSphere = i;
            }
        }
    }

    if (closestSphere >= 0)
    {
        sphere s = spheres[closestSphere];
        vec3 hitPoint = rayAt(r, closestT);
        vec3 normal = normalize(hitPoint - s.centre);

        float lightIntensity = dot(normal, light);

        return vec4(s.col * lightIntensity, 1.0);
    }

    vec3 unitDirection = normalize(r.direction);
    float t = 0.5*(unitDirection.y + 1.0);
    return vec4((1.0-t)*vec3(1.0, 1.0, 1.0) + t*vec3(0.3, 0.5, 1.0), 1.0);
}

void main()
{
    float aspectRatio = iResolution.x/iResolution.y;
    vec2 uv = gl_FragCoord.xy/iResolution.xy - 0.5;
    uv.x *= aspectRatio;

    vec3 camPos = vec3(0.0, 0.0, 3.0);
    vec3 camLookAt = vec3(0.0, 0.0, 0.0);

    vec3 camDir = normalize(camLookAt - camPos);
    vec3 camRight = normalize(cross(camDir, vec3(0.0, 1.0, 0.0)));
    vec3 camUp = normalize(cross(camRight, camDir));

    vec3 rayDir = camDir + uv.x*camRight + uv.y*camUp;

    ray r;
    r.origin = camPos;
    r.direction = rayDir;

    gl_FragColor = rayColour(r);
}