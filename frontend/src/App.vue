<script setup lang="ts">
import { onMounted, ref } from 'vue'
import { getProfile, getProjects, sendContact } from './api'
import type { Profile, Project } from './types'

const profile = ref<Profile | null>(null)
const projects = ref<Project[]>([])
const pageError = ref('')
const sending = ref(false)
const formMessage = ref('')
const formError = ref('')
const form = ref({ name: '', email: '', message: '' })

onMounted(async () => {
  try {
    const [profileData, projectData] = await Promise.all([getProfile(), getProjects()])
    profile.value = profileData
    projects.value = projectData
  } catch {
    pageError.value = 'No se pudo conectar con la API. Revisa que el backend esté activo.'
  }
})

async function submitContact() {
  formMessage.value = ''
  formError.value = ''
  sending.value = true
  try {
    const result = await sendContact(form.value)
    formMessage.value = result.message
    form.value = { name: '', email: '', message: '' }
  } catch (error) {
    formError.value = error instanceof Error ? error.message : 'No se pudo enviar el mensaje.'
  } finally {
    sending.value = false
  }
}
</script>

<template>
  <div class="site-shell">
    <header class="topbar">
      <a class="brand" href="#inicio" aria-label="Wendy Ramírez, ir al inicio">
        <span class="brand-mark">W</span><span>wendy<span class="brand-dot">.</span></span>
      </a>
      <nav aria-label="Navegación principal">
        <a href="#sobre-mi">Sobre mí</a>
        <a href="#proyectos">Proyectos</a>
        <a class="nav-contact" href="#contacto">Hablemos <span aria-hidden="true">↗</span></a>
      </nav>
    </header>

    <main>
      <section id="inicio" class="hero section-wrap">
        <div class="hero-copy">
          <p class="eyebrow"><span class="status-dot"></span> PORTAFOLIO PERSONAL · 2026</p>
          <h1>Ideas que<br />se vuelven <span class="serif-accent">experiencias.</span></h1>
          <p class="hero-description">{{ profile?.intro ?? 'Diseño y desarrollo soluciones digitales con curiosidad, intención y mucho cuidado.' }}</p>
          <div class="hero-actions">
            <a class="button button-primary" href="#proyectos">Explorar proyectos <span aria-hidden="true">↓</span></a>
            <a class="text-link" href="#sobre-mi">Conoce mi historia <span aria-hidden="true">↗</span></a>
          </div>
          <div class="hero-meta"><span>INGENIERÍA DE SISTEMAS</span><span>SUCRE, BOLIVIA</span></div>
        </div>
        <div class="hero-art" aria-label="Composición abstracta en violeta" role="img">
          <div class="art-orbit orbit-one"></div><div class="art-orbit orbit-two"></div>
          <div class="art-core"><span>W</span></div>
          <span class="art-star star-one">✳</span><span class="art-star star-two">✦</span>
          <span class="art-caption">CREATIVIDAD<br />CON PROPÓSITO</span>
          <span class="art-index">01 / 04</span>
        </div>
        <a class="scroll-cue" href="#sobre-mi"><span></span> DESLIZA PARA EXPLORAR</a>
      </section>

      <section id="sobre-mi" class="about section-wrap">
        <div class="section-kicker"><span>01</span><span>UN POCO SOBRE MÍ</span></div>
        <div class="about-grid">
          <h2>Una mente curiosa,<br /><span class="serif-accent">muchas formas</span><br />de crear.</h2>
          <div class="about-copy">
            <p class="about-lead">Hola, soy {{ profile?.name ?? 'Wendy Ramírez' }}.</p>
            <p>{{ profile?.role ?? 'Estudiante de Ingeniería de Sistemas' }} en UNIVALLE, Sucre. Me gusta convertir desafíos cotidianos en proyectos digitales que se sientan claros, útiles y humanos.</p>
            <p>Entre código, diseño y mundos virtuales, siempre encuentro algo nuevo que aprender y construir.</p>
            <div class="skill-list"><span>Desarrollo web</span><span>Experiencias XR</span><span>Diseño de sistemas</span></div>
          </div>
        </div>
      </section>

      <section id="proyectos" class="projects-section">
        <div class="section-wrap">
          <div class="section-kicker"><span>02</span><span>SELECCIÓN DE PROYECTOS</span></div>
          <div class="projects-heading"><h2>Hecho con intención<span class="serif-accent">.</span></h2><p>Ideas que tomaron forma<br />a través del código y la creatividad.</p></div>
          <p v-if="pageError" class="notice" role="status">{{ pageError }}</p>
          <div class="project-grid">
            <article v-for="(project, index) in projects" :key="project.title" class="project-card" :class="`project-card-${index + 1}`">
              <div class="project-visual" :class="`visual-${index + 1}`">
                <span class="visual-number">0{{ index + 1 }}</span>
                <div v-if="index === 0" class="mini-window"><div class="mini-dots"><i></i><i></i><i></i></div><div class="mini-lines"><b></b><b></b><b></b></div></div>
                <div v-else-if="index === 1" class="forest-shape"><i></i><i></i><i></i><span>✦</span></div>
                <div v-else class="community-shape"><span>✳</span><i></i><i></i><i></i></div>
                <span class="visual-arrow" aria-hidden="true">↗</span>
              </div>
              <div class="project-info"><p class="project-category">{{ project.category }}</p><h3>{{ project.title }}</h3><p class="project-description">{{ project.description }}</p><div class="tag-row"><span v-for="tag in project.tags" :key="tag">{{ tag }}</span></div></div>
            </article>
          </div>
        </div>
      </section>

      <section id="contacto" class="contact-section section-wrap">
        <div class="section-kicker"><span>03</span><span>EL SIGUIENTE PASO</span></div>
        <div class="contact-grid">
          <div><p class="eyebrow">¿TIENES UNA IDEA?</p><h2>Hagamos algo<br /><span class="serif-accent">bonito juntos.</span></h2><p class="contact-copy">Si quieres conversar sobre un proyecto, una colaboración o simplemente saludar, aquí puedes escribirme.</p><p class="contact-note">Los mensajes enviados desde este formulario llegan a la base de datos del portafolio.</p></div>
          <form class="contact-form" @submit.prevent="submitContact">
            <label>Tu nombre<input v-model="form.name" name="name" autocomplete="name" required minlength="2" placeholder="¿Cómo te llamas?" /></label>
            <label>Tu correo<input v-model="form.email" name="email" type="email" autocomplete="email" required placeholder="hola@ejemplo.com" /></label>
            <label>Cuéntame un poco<textarea v-model="form.message" name="message" required minlength="10" rows="4" placeholder="¿Qué tienes en mente?"></textarea></label>
            <button class="button button-primary submit-button" type="submit" :disabled="sending">{{ sending ? 'Enviando…' : 'Enviar mensaje' }} <span aria-hidden="true">↗</span></button>
            <p v-if="formMessage" class="form-success" role="status">{{ formMessage }}</p>
            <p v-if="formError" class="form-error" role="alert">{{ formError }}</p>
          </form>
        </div>
      </section>
    </main>

    <footer class="footer"><a class="brand" href="#inicio"><span class="brand-mark">W</span><span>wendy<span class="brand-dot">.</span></span></a><span>HECHO CON CURIOSIDAD EN SUCRE, BOLIVIA</span><a href="#inicio">VOLVER ARRIBA ↑</a></footer>
  </div>
</template>
