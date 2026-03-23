# Categorías principales
educacion = Category.find_or_create_by!(slug: "educacion") { |c| c.name = "Educación" }
salud = Category.find_or_create_by!(slug: "salud") { |c| c.name = "Salud y Bienestar" }
tecnologia = Category.find_or_create_by!(slug: "tecnologia") { |c| c.name = "Tecnología" }
profesional = Category.find_or_create_by!(slug: "profesional") { |c| c.name = "Servicios Profesionales" }
creativo = Category.find_or_create_by!(slug: "creativo") { |c| c.name = "Creativo y Diseño" }

# Subcategorías Educación
matematica = Category.find_or_create_by!(slug: "matematica", parent_id: educacion.id) { |c| c.name = "Matemática" }
fisica = Category.find_or_create_by!(slug: "fisica", parent_id: educacion.id) { |c| c.name = "Física" }
quimica = Category.find_or_create_by!(slug: "quimica", parent_id: educacion.id) { |c| c.name = "Química" }
idiomas = Category.find_or_create_by!(slug: "idiomas", parent_id: educacion.id) { |c| c.name = "Idiomas" }
prog_cat = Category.find_or_create_by!(slug: "programacion", parent_id: educacion.id) { |c| c.name = "Programación" }

# Subcategorías Salud
psicologia = Category.find_or_create_by!(slug: "psicologia", parent_id: salud.id) { |c| c.name = "Psicología" }
nutricion = Category.find_or_create_by!(slug: "nutricion", parent_id: salud.id) { |c| c.name = "Nutrición" }
yoga = Category.find_or_create_by!(slug: "yoga", parent_id: salud.id) { |c| c.name = "Yoga y Meditación" }
fisioterapia = Category.find_or_create_by!(slug: "fisioterapia", parent_id: salud.id) { |c| c.name = "Fisioterapia" }

# Subcategorías Tecnología
desarrollo_web = Category.find_or_create_by!(slug: "desarrollo-web", parent_id: tecnologia.id) { |c| c.name = "Desarrollo Web" }
diseno_ux = Category.find_or_create_by!(slug: "diseno-ux", parent_id: tecnologia.id) { |c| c.name = "Diseño UX/UI" }
data_science = Category.find_or_create_by!(slug: "data-science", parent_id: tecnologia.id) { |c| c.name = "Data Science" }

# Subcategorías Profesional
asesoria_legal = Category.find_or_create_by!(slug: "asesoria-legal", parent_id: profesional.id) { |c| c.name = "Asesoría Legal" }
contabilidad = Category.find_or_create_by!(slug: "contabilidad", parent_id: profesional.id) { |c| c.name = "Contabilidad" }
marketing = Category.find_or_create_by!(slug: "marketing", parent_id: profesional.id) { |c| c.name = "Marketing" }

# Subcategorías Creativo
fotografia = Category.find_or_create_by!(slug: "fotografia", parent_id: creativo.id) { |c| c.name = "Fotografía" }
video_edicion = Category.find_or_create_by!(slug: "video-edicion", parent_id: creativo.id) { |c| c.name = "Edición de Video" }
musica = Category.find_or_create_by!(slug: "musica", parent_id: creativo.id) { |c| c.name = "Música" }

# Datos de prueba
if User.count == 0
  puts "Creando profesionales de prueba..."

  professionals_data = [
    {
      name: "María González",
      email: "maria@example.com",
      password: "password123",
      headline: "Profesora de Matemática con 10 años de experiencia",
      bio: "Licenciada en Matemática de la UBA. Especializada en nivel secundario y preparación para exámenes de ingreso a la universidad.",
      categories: [ matematica, fisica ],
      services: [
        { title: "Clase de Matemática - Nivel Secundario", price: 15000, duration: 60, category: matematica },
        { title: "Preparación Examen de Ingreso", price: 20000, duration: 90, category: matematica },
        { title: "Clase de Física", price: 15000, duration: 60, category: fisica }
      ],
      rating: 4.8,
      rating_count: 42
    },
    {
      name: "Carlos Rodríguez",
      email: "carlos@example.com",
      password: "password123",
      headline: "Desarrollador Full Stack y Mentor de Programación",
      bio: "Ingeniero en Informática con 8 años de experiencia en desarrollo web. Trabajé en empresas como Globant y MercadoLibre. Apasionado por enseñar Ruby, Rails y JavaScript.",
      categories: [ prog_cat, desarrollo_web ],
      services: [
        { title: "Mentoría de Programación - 1 hora", price: 18000, duration: 60, category: prog_cat },
        { title: "Code Review de tu Proyecto", price: 25000, duration: 60, category: desarrollo_web },
        { title: "Clase de Ruby on Rails", price: 20000, duration: 90, category: desarrollo_web }
      ],
      rating: 4.9,
      rating_count: 38
    },
    {
      name: "Ana Martínez",
      email: "ana@example.com",
      password: "password123",
      headline: "Psicóloga Clínica - Terapia Cognitivo Conductual",
      bio: "Psicóloga matriculada MP 12345. Especializada en terapia cognitivo conductual para ansiedad, depresión y estrés. Atención online e hispanohablante.",
      categories: [ psicologia ],
      services: [
        { title: "Sesión de Terapia Individual", price: 25000, duration: 50, category: psicologia },
        { title: "Consulta Inicial", price: 20000, duration: 40, category: psicologia }
      ],
      rating: 5.0,
      rating_count: 27
    },
    {
      name: "Diego Fernández",
      email: "diego@example.com",
      password: "password123",
      headline: "Profesor de Inglés - Certificado Cambridge C2",
      bio: "Profesor de inglés con certificación Cambridge C2. Más de 12 años enseñando inglés a hispanohablantes. Especializado en conversación y preparación para exámenes.",
      categories: [ idiomas ],
      services: [
        { title: "Clase de Conversación en Inglés", price: 12000, duration: 45, category: idiomas },
        { title: "Preparación TOEFL/IELTS", price: 18000, duration: 60, category: idiomas },
        { title: "Inglés para Negocios", price: 20000, duration: 60, category: idiomas }
      ],
      rating: 4.7,
      rating_count: 55
    },
    {
      name: "Laura Sánchez",
      email: "laura@example.com",
      password: "password123",
      headline: "Nutricionista Deportiva",
      bio: "Licenciada en Nutrición con especialización en deportes. Ayudo a atletas y personas activas a optimizar su alimentación para alcanzar sus objetivos.",
      categories: [ nutricion ],
      services: [
        { title: "Consulta Nutricional", price: 15000, duration: 45, category: nutricion },
        { title: "Plan Alimentario Personalizado", price: 22000, duration: 60, category: nutricion },
        { title: "Seguimiento Mensual", price: 35000, duration: 30, category: nutricion }
      ],
      rating: 4.9,
      rating_count: 33
    },
    {
      name: "Roberto López",
      email: "roberto@example.com",
      password: "password123",
      headline: "Desarrollador Senior Ruby on Rails",
      bio: "Desarrollador Ruby on Rails desde 2011. Ex-Core Team member de Rails. Me especializo en arquitectura, performance y best practices.",
      categories: [ desarrollo_web, prog_cat ],
      services: [
        { title: "Mentoría Técnica - Rails", price: 25000, duration: 60, category: desarrollo_web },
        { title: "Code Review y Arquitectura", price: 30000, duration: 90, category: desarrollo_web },
        { title: "Pair Programming Session", price: 20000, duration: 60, category: prog_cat }
      ],
      rating: 5.0,
      rating_count: 19
    },
    {
      name: "Patricia Silva",
      email: "patricia@example.com",
      password: "password123",
      headline: "Diseñadora UX/UI con experiencia en startups",
      bio: "Diseñadora de producto con background en psicología. Trabajé en varias startups fintech y healthtech. Me apasiona crear experiencias que los usuarios amen.",
      categories: [ diseno_ux ],
      services: [
        { title: "Mentoría de Diseño UX", price: 16000, duration: 60, category: diseno_ux },
        { title: "Review de tu Portfolio", price: 12000, duration: 45, category: diseno_ux },
        { title: "Asesoría de Proyecto", price: 22000, duration: 60, category: diseno_ux }
      ],
      rating: 4.8,
      rating_count: 22
    },
    {
      name: "Miguel Ángel Torres",
      email: "miguel@example.com",
      password: "password123",
      headline: "Profesor de Química - Universitario",
      bio: "Doctor en Química de la UBA. Profesor universitario desde hace 15 años. Experto en química orgánica y ayudante en trabajos de tesis.",
      categories: [ quimica, matematica ],
      services: [
        { title: "Clase de Química Orgánica", price: 18000, duration: 60, category: quimica },
        { title: "Asesoría de Tesis", price: 25000, duration: 90, category: quimica },
        { title: "Clase de Química General", price: 15000, duration: 60, category: quimica }
      ],
      rating: 4.6,
      rating_count: 18
    }
  ]

  professionals_data.each do |prof_data|
    # Crear usuario
    user = User.create!(
      email: prof_data[:email],
      password: prof_data[:password],
      name: prof_data[:name],
      role: :client
    )

    # Crear profesional
    professional = Professional.create!(
      user: user,
      headline: prof_data[:headline],
      bio: prof_data[:bio],
      verified: true,
      rating_avg: prof_data[:rating],
      rating_count: prof_data[:rating_count]
    )

    # Asignar categorías
    prof_data[:categories].each do |cat|
      professional.categories << cat
    end

    # Crear servicios
    prof_data[:services].each do |service_data|
      Service.create!(
        professional: professional,
        title: service_data[:title],
        description: "Sesión personalizada adaptada a tus necesidades.",
        price: service_data[:price],
        duration_minutes: service_data[:duration],
        category: service_data[:category],
        active: true
      )
    end

    # Crear política de cancelación
    CancellationPolicy.create!(
      professional: professional,
      free_cancel_hours_before: 24,
      late_cancel_refund_percent: 0
    )

    puts "✓ Creado: #{prof_data[:name]}"
  end

  puts "\nTotal profesionales: #{Professional.count}"
  puts "Total servicios: #{Service.count}"
end
